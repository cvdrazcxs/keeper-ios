import Dispatch
import Foundation

public enum MinimumRefreshDurationBehavior {
    public static let minimumDuration: TimeInterval = 0.5

    public static func perform<T>(_ action: @escaping @Sendable () async -> T) async -> T {
        async let result = action()
        async let delay: Void = {
            let nanoseconds = UInt64(minimumDuration * Double(NSEC_PER_SEC))
            try? await Task.sleep(nanoseconds: nanoseconds)
        }()

        let value = await result
        await delay
        return value
    }
}
