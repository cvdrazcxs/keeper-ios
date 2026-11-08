import Foundation
import TKLogging

struct NativeSwapSseSessionOutput {
    var emit: (SwapConfirmation) -> Void
    var finalize: (Result<Void, NativeSwapAPIError>) -> Void
}

actor NativeSwapSseSession {
    enum State {
        case idle
        case active(Task<Void, Never>)
        case canceled
    }

    private let configuration: Configuration
    private let network: Network
    private let data: SwapConfirmationData
    private let decoder = JSONDecoder()
    private var state: State = .idle

    init(
        network: Network,
        data: SwapConfirmationData,
        configuration: Configuration
    ) {
        self.network = network
        self.data = data
        self.configuration = configuration
    }

    func start(output: NativeSwapSseSessionOutput) async {
        switch state {
        case .idle:
            state = .active(createSession(output: output))
        case .canceled:
            output.finalize(.success(()))
        case .active:
            return
        }
    }

    func cancel() {
        switch state {
        case .idle:
            state = .canceled
        case let .active(task):
            state = .canceled
            task.cancel()
        case .canceled:
            break
        }
    }

    private func createSession(output: NativeSwapSseSessionOutput) -> Task<Void, Never> {
        Task {
            guard !Task.isCancelled else {
                Log.nativeSwapAPI.d("Stream task cancelled before starting")
                return output.finalize(.success(()))
            }

            let streamSession = URLSession(
                configuration: {
                    let configuration: URLSessionConfiguration = .default
                    configuration.timeoutIntervalForRequest = 300 // 5 minutes
                    configuration.timeoutIntervalForResource = 3600 // 1 hour
                    return configuration
                }()
            )

            defer {
                streamSession.finishTasksAndInvalidate()
            }

            do {
                let url = configuration
                    .swapHostURL(network: network)
                    .appendingPathComponent("v2/swap/omniston/stream")

                let queryItems: [URLQueryItem] = [
                    URLQueryItem(name: "fromAsset", value: data.fromAsset),
                    URLQueryItem(name: "toAsset", value: data.toAsset),
                    URLQueryItem(name: "userAddress", value: data.userAddress),
                ] + [
                    data.isSend
                        ? URLQueryItem(name: "fromAmount", value: data.fromAmount)
                        : URLQueryItem(name: "toAmount", value: data.toAmount),
                ]

                let urlComponents = {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    components?.queryItems = queryItems
                    return components
                }()

                guard let requestURL = urlComponents?.url else {
                    Log.nativeSwapAPI.e("Failed to construct request URL from: \(url.absoluteString)")
                    return output.finalize(.failure(.incorrectHost(url.absoluteString)))
                }

                Log.nativeSwapAPI.d("Starting SSE stream: \(requestURL.absoluteString)")

                let urlRequest = {
                    var request = URLRequest(url: requestURL)
                    request.httpMethod = "GET"
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    return request
                }()

                let (bytes, response) = try await streamSession.bytes(for: urlRequest)

                if let httpResponse = response as? HTTPURLResponse {
                    Log.nativeSwapAPI.d("SSE stream connected with status: \(httpResponse.statusCode)")
                }

                var eventCount = 0

                for try await line in bytes.lines {
                    guard !Task.isCancelled else {
                        Log.nativeSwapAPI.d("Stream task cancelled, received \(eventCount) events")
                        return output.finalize(.success(()))
                    }

                    guard line.hasPrefix("data: ") else { continue }

                    let jsonString = String(line.dropFirst(6))

                    // Skip connection confirmation events
                    if jsonString.contains("\"type\":\"connected\"") {
                        Log.nativeSwapAPI.d("SSE connection confirmed")
                        continue
                    }

                    // Handle error events
                    if jsonString.contains("\"error\":") {
                        Log.nativeSwapAPI.w("Server returned error event: \(jsonString)")
                        return output.finalize(.failure(.serverError))
                    }

                    // Decode swap confirmation
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        Log.nativeSwapAPI.w("Failed to convert SSE data to UTF8")
                        continue
                    }

                    do {
                        let model = try self.decoder.decode(SwapConfirmation.self, from: jsonData)
                        eventCount += 1
                        Log.nativeSwapAPI.d("Received swap confirmation #\(eventCount): bidUnits=\(model.bidUnits), askUnits=\(model.askUnits)")
                        output.emit(model)
                    } catch {
                        Log.nativeSwapAPI.w("Failed to decode swap confirmation: \(error.localizedDescription)")
                        continue
                    }
                }

                Log.nativeSwapAPI.i("SSE stream finished normally, received \(eventCount) events")
                return output.finalize(.success(()))
            } catch is CancellationError {
                Log.nativeSwapAPI.d("SSE stream cancelled")
                return output.finalize(.success(()))
            } catch {
                Log.nativeSwapAPI.w("SSE stream error: \(error.localizedDescription)")
                return output.finalize(.failure(.streamingFailed(message: error.localizedDescription)))
            }
        }
    }
}
