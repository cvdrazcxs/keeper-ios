@testable import App
import Foundation
import KeeperCoreSensitive
import XCTest

final class Argon2DeriveTimeMeasurementControllerTests: XCTestCase {
    func test_runInBackgroundIfNeeded_sendsSuccessMeasurementAndMarksMeasurementDone() async throws {
        let userDefaults = makeUserDefaults(suiteName: #function)
        defer {
            resetUserDefaults(suiteName: #function)
        }
        let analyticsSpy = AnalyticsLoggerSpy()
        var nowValues: [TimeInterval] = [100, 100.065]
        var measuredPassword: String?
        var measuredMnemonic: CoreMnemonic?
        let mnemonic = CoreMnemonic(
            mnemonicWords: ["one", "two", "three"],
            type: .unknown
        )
        let controller = makeController(
            userDefaults: userDefaults,
            logEvent: analyticsSpy.log,
            makePassword: {
                "mock-password"
            },
            makeMnemonic: {
                mnemonic
            },
            measureEncryptDecrypt: { mnemonic, password, _ in
                measuredPassword = password
                measuredMnemonic = mnemonic
                return .success(
                    encryptDuration: 0.031,
                    decryptDuration: 0.029
                )
            },
            now: {
                nowValues.removeFirst()
            }
        )

        await controller.runInBackgroundIfNeeded()
        userDefaults.synchronize()

        XCTAssertEqual(measuredPassword, "mock-password")
        XCTAssertEqual(measuredMnemonic, mnemonic)
        XCTAssertEqual(
            userDefaults.bool(forKey: "v1_did_run_argon2_derive_time_measurement"),
            true
        )
        XCTAssertEqual(analyticsSpy.loggedEvents.count, 1)
        let event = try XCTUnwrap(analyticsSpy.loggedEvents.first)
        XCTAssertEqual(event.name, "custom_error")
        XCTAssertEqual(event.args["error_message"] as? String, "argon2_derive_time_measurement")

        let metadata = try parseMetadata(event: event)
        XCTAssertEqual(metadata["status"] as? String, "success")
        XCTAssertEqual(intValue(metadata["encrypt_duration_ms"]), 31)
        XCTAssertEqual(intValue(metadata["decrypt_duration_ms"]), 29)
        XCTAssertEqual(intValue(metadata["total_duration_ms"]), 65)
        XCTAssertEqual(metadata["device_model"] as? String, "iPhone15,3")
    }

    func test_runInBackgroundIfNeeded_sendsFailureMeasurementAndMarksMeasurementDone() async throws {
        let userDefaults = makeUserDefaults(suiteName: #function)
        defer {
            resetUserDefaults(suiteName: #function)
        }
        let analyticsSpy = AnalyticsLoggerSpy()
        var nowValues: [TimeInterval] = [200, 200.045]
        let controller = makeController(
            userDefaults: userDefaults,
            logEvent: analyticsSpy.log,
            measureEncryptDecrypt: { _, _, _ in
                .failure(
                    step: .decrypt,
                    encryptDuration: 0.025,
                    decryptDuration: 0.020,
                    error: TestError.decryptFailed
                )
            },
            now: {
                nowValues.removeFirst()
            }
        )

        await controller.runInBackgroundIfNeeded()
        userDefaults.synchronize()

        XCTAssertEqual(
            userDefaults.bool(forKey: "v1_did_run_argon2_derive_time_measurement"),
            true
        )
        XCTAssertEqual(analyticsSpy.loggedEvents.count, 1)
        let metadata = try parseMetadata(event: XCTUnwrap(analyticsSpy.loggedEvents.first))
        XCTAssertEqual(metadata["status"] as? String, "failure")
        XCTAssertEqual(metadata["failure_step"] as? String, "decrypt")
        XCTAssertEqual(metadata["error_type"] as? String, "TestError")
        XCTAssertEqual(intValue(metadata["encrypt_duration_ms"]), 25)
        XCTAssertEqual(intValue(metadata["decrypt_duration_ms"]), 20)
        XCTAssertEqual(intValue(metadata["total_duration_ms"]), 45)
    }

    func test_runInBackgroundIfNeeded_runsOnlyOnce() async {
        let userDefaults = makeUserDefaults(suiteName: #function)
        defer {
            resetUserDefaults(suiteName: #function)
        }
        var measurementsCount = 0
        let controller = makeController(
            userDefaults: userDefaults,
            measureEncryptDecrypt: { _, _, _ in
                measurementsCount += 1
                return .success(
                    encryptDuration: 0.001,
                    decryptDuration: 0.001
                )
            },
            now: makeIncrementingClock()
        )

        await controller.runInBackgroundIfNeeded()
        await controller.runInBackgroundIfNeeded()
        userDefaults.synchronize()

        XCTAssertEqual(measurementsCount, 1)
        XCTAssertEqual(
            userDefaults.bool(forKey: "v1_did_run_argon2_derive_time_measurement"),
            true
        )

        let nextLaunchController = makeController(
            userDefaults: userDefaults,
            measureEncryptDecrypt: { _, _, _ in
                measurementsCount += 1
                return .success(
                    encryptDuration: 0.001,
                    decryptDuration: 0.001
                )
            },
            now: makeIncrementingClock()
        )

        await nextLaunchController.runInBackgroundIfNeeded()
        userDefaults.synchronize()

        XCTAssertEqual(measurementsCount, 1)
        XCTAssertEqual(
            userDefaults.bool(forKey: "v1_did_run_argon2_derive_time_measurement"),
            true
        )
    }

    func test_runInBackgroundIfNeeded_doesNotRunAfterMeasurementDone() async {
        let userDefaults = makeUserDefaults(suiteName: #function)
        defer {
            resetUserDefaults(suiteName: #function)
        }
        userDefaults.set(
            true,
            forKey: "v1_did_run_argon2_derive_time_measurement"
        )
        var didMeasure = false
        let analyticsSpy = AnalyticsLoggerSpy()
        let controller = makeController(
            userDefaults: userDefaults,
            logEvent: analyticsSpy.log,
            measureEncryptDecrypt: { _, _, _ in
                didMeasure = true
                return .success(
                    encryptDuration: 0.001,
                    decryptDuration: 0.001
                )
            },
            now: makeIncrementingClock()
        )

        let needsMeasurement = await controller.needsMeasurement
        XCTAssertFalse(needsMeasurement)

        await controller.runInBackgroundIfNeeded()
        userDefaults.synchronize()

        XCTAssertFalse(didMeasure)
        XCTAssertTrue(analyticsSpy.loggedEvents.isEmpty)
        XCTAssertEqual(
            userDefaults.bool(forKey: "v1_did_run_argon2_derive_time_measurement"),
            true
        )
    }
}

private extension Argon2DeriveTimeMeasurementControllerTests {
    func makeController(
        userDefaults: UserDefaults,
        logEvent: @escaping (_ event: Encodable) -> Void = { _ in },
        makePassword: @escaping () -> String = {
            "password"
        },
        makeMnemonic: @escaping () -> CoreMnemonic = {
            CoreMnemonic(
                mnemonicWords: ["one", "two", "three"],
                type: .unknown
            )
        },
        measureEncryptDecrypt: @escaping (
            _ mnemonic: CoreMnemonic,
            _ password: String,
            _ now: () -> TimeInterval
        ) -> Argon2DeriveTimeMeasurementController.MeasurementResult,
        now: @escaping () -> TimeInterval
    ) -> Argon2DeriveTimeMeasurementController {
        Argon2DeriveTimeMeasurementController(
            dependencies: Argon2DeriveTimeMeasurementControllerDependencies(
                logEvent: logEvent,
                makePassword: makePassword,
                makeMnemonic: makeMnemonic,
                measureEncryptDecrypt: measureEncryptDecrypt,
                now: now,
                userDefaults: userDefaults,
                schedule: { operation in
                    await operation()
                },
                processMetadata: {
                    [
                        "device_model": "iPhone15,3",
                        "low_power_mode_enabled": false,
                        "thermal_state": "nominal",
                    ]
                }
            )
        )
    }

    func parseMetadata(
        event: (name: String, args: [String: Any])
    ) throws -> [String: Any] {
        let otherMetadata = try XCTUnwrap(event.args["other_metadata"] as? String)
        let otherMetadataData = try XCTUnwrap(otherMetadata.data(using: .utf8))
        return try XCTUnwrap(
            JSONSerialization.jsonObject(with: otherMetadataData) as? [String: Any]
        )
    }

    func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }
        return (value as? NSNumber)?.intValue
    }

    func makeIncrementingClock() -> () -> TimeInterval {
        var value: TimeInterval = 0
        return {
            value += 0.001
            return value
        }
    }

    func makeUserDefaults(suiteName: String) -> UserDefaults {
        let normalizedSuiteName = normalizedSuiteName(for: suiteName)
        let userDefaults = UserDefaults(suiteName: normalizedSuiteName) ?? .standard
        userDefaults.removePersistentDomain(forName: normalizedSuiteName)
        return userDefaults
    }

    func resetUserDefaults(suiteName: String) {
        let normalizedSuiteName = normalizedSuiteName(for: suiteName)
        UserDefaults(suiteName: normalizedSuiteName)?.removePersistentDomain(forName: normalizedSuiteName)
    }

    func normalizedSuiteName(for suiteName: String) -> String {
        "com.tonkeeper.tests." + suiteName
            .replacingOccurrences(of: "[^A-Za-z0-9_.-]", with: "_", options: .regularExpression)
    }
}

private final class AnalyticsLoggerSpy {
    private(set) var loggedEvents = [(name: String, args: [String: Any])]()

    func log(_ event: Encodable) {
        guard var dict = AnyEncodable(event).asDictionary() else {
            XCTFail("Failed to encode event")
            return
        }

        guard let name = dict.removeValue(forKey: "eventName") as? String else {
            XCTFail("Missing eventName")
            return
        }

        loggedEvents.append((name: name, args: dict))
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ value: Encodable) {
        encodeClosure = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

private extension AnyEncodable {
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dict = object as? [String: Any]
        else {
            return nil
        }
        return dict
    }
}

private enum TestError: Error {
    case decryptFailed
}
