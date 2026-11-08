import Foundation
import KeeperCore

final class DepositPendingTracker {
    private let now: () -> Date
    private let lock = NSLock()
    private var pendingExpirations = [String: Date]()

    init(now: @escaping () -> Date = { Date() }) {
        self.now = now
    }

    func markPending(wallet: Wallet) {
        lock.lock()
        defer { lock.unlock() }
        pendingExpirations[wallet.id] = now().addingTimeInterval(30 * 60)
    }

    func consumeIfPending(wallet: Wallet) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let expiration = pendingExpirations.removeValue(forKey: wallet.id) else {
            return false
        }
        return now() <= expiration
    }
}
