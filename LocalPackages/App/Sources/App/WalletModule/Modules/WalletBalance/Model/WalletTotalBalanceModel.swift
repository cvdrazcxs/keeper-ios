import Foundation
import KeeperCore
import TKCore
import TonSwift

final class WalletTotalBalanceModel: @unchecked Sendable {
    struct State {
        let address: FriendlyAddress
        let totalBalanceState: TotalBalanceState?
        let isSecure: Bool
        let backgroundUpdateConnectionState: BackgroundUpdateConnectionState
        let isLoadingBalance: Bool
    }

    var didUpdateState: ((State) -> Void)?

    let wallet: Wallet

    private let totalBalanceStore: TotalBalanceStore
    private let appSettingsStore: AppSettingsStore
    private let appSettings: TKCore.AppSettings?
    private let backgroundUpdate: BackgroundUpdate
    private let updateQueue: DispatchQueue

    private let loadingLock = NSLock()
    private var isLoadingBalance = false

    private var backgroundStateTask: Task<Void, Never>?
    private var userDefaultsObserver: (any NSObjectProtocol)?
    private var lastFakeBalanceSignature = ""

    init(
        wallet: Wallet,
        totalBalanceStore: TotalBalanceStore,
        appSettingsStore: AppSettingsStore,
        backgroundUpdate: BackgroundUpdate,
        balanceLoader: BalanceLoader,
        updateQueue: DispatchQueue,
        appSettings: TKCore.AppSettings? = nil
    ) {
        self.wallet = wallet
        self.totalBalanceStore = totalBalanceStore
        self.appSettingsStore = appSettingsStore
        self.appSettings = appSettings
        self.backgroundUpdate = backgroundUpdate
        self.updateQueue = updateQueue

        totalBalanceStore.addObserver(self) { observer, event in
            observer.didGetTotalBalanceStoreEvent(event)
        }

        appSettingsStore.addObserver(self) { observer, _ in
            observer.updateQueue.async { [weak observer] in
                observer?.updateModel()
            }
        }

        balanceLoader.addUpdateObserver(self) { observer, update in
            observer.setLoading(update.isLoading, for: update.wallet)
            observer.didGetWalletScopedEvent(update.wallet)
        }

        backgroundStateTask = Task { [weak self, walletID = wallet.id] in
            for await update in backgroundUpdate.stateUpdates() {
                guard update.walletID == walletID else { continue }
                guard let self else { return }
                didGetWalletScopedEvent(wallet)
            }
        }

        // Fork: the fake balance lives in UserDefaults, so refresh the header
        // whenever one of its keys changes (toggle / editing in settings).
        guard let appSettings else { return }
        userDefaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            self.updateQueue.async { [weak self] in
                guard let self else { return }
                let signature = Self.fakeBalanceSignature(appSettings)
                guard signature != self.lastFakeBalanceSignature else { return }
                self.lastFakeBalanceSignature = signature
                self.updateModel()
            }
        }
    }

    deinit {
        backgroundStateTask?.cancel()
        if let userDefaultsObserver {
            NotificationCenter.default.removeObserver(userDefaultsObserver)
        }
    }

    private static func fakeBalanceSignature(_ appSettings: TKCore.AppSettings) -> String {
        "\(appSettings.isFakeBalanceEnabled)|\(appSettings.fakeBalanceAmount ?? "-")|\(appSettings.fakeBalanceSymbol ?? "-")"
    }

    func getState() throws -> State {
        try State(
            address: wallet.friendlyAddress,
            totalBalanceState: totalBalanceStore.state[wallet],
            isSecure: appSettingsStore.state.isSecureMode,
            backgroundUpdateConnectionState: backgroundUpdate.connectionState(walletID: wallet.id),
            isLoadingBalance: loadingLock.withLock { isLoadingBalance }
        )
    }

    private func setLoading(_ isLoading: Bool, for wallet: Wallet) {
        guard wallet == self.wallet else { return }
        loadingLock.withLock { isLoadingBalance = isLoading }
    }

    private func didGetTotalBalanceStoreEvent(_ event: TotalBalanceStore.Event) {
        switch event {
        case let .didUpdateTotalBalance(wallet):
            didGetWalletScopedEvent(wallet)
        }
    }

    private func didGetWalletScopedEvent(_ wallet: Wallet) {
        guard wallet == self.wallet else { return }
        updateQueue.async { [weak self] in
            self?.updateModel()
        }
    }

    private func updateModel() {
        guard let state = try? getState() else { return }
        didUpdateState?(state)
    }
}
