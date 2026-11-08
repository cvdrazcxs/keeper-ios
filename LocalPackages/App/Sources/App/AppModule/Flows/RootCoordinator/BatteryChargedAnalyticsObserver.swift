import Foundation
import KeeperCore
import TKCore

final class BatteryChargedAnalyticsObserver {
    private let totalBalanceStore: TotalBalanceStore
    private let analyticsProvider: AnalyticsProvider
    private var lastBalances: [Wallet: NSDecimalNumber] = [:]

    init(
        totalBalanceStore: TotalBalanceStore,
        analyticsProvider: AnalyticsProvider
    ) {
        self.totalBalanceStore = totalBalanceStore
        self.analyticsProvider = analyticsProvider

        totalBalanceStore.addObserver(self) { observer, event in
            switch event {
            case let .didUpdateTotalBalance(wallet):
                observer.handleUpdate(for: wallet)
            }
        }
    }

    private func handleUpdate(for wallet: Wallet) {
        let current = totalBalanceStore.state[wallet]?.totalBalance?.batteryBalance?.balanceDecimalNumber ?? .zero
        if let last = lastBalances[wallet], current.compare(last) == .orderedDescending {
            analyticsProvider.logBatteryCharged()
        }
        lastBalances[wallet] = current
    }
}
