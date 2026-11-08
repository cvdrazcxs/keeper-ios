import Foundation
import KeeperCoreComponents
import KeeperCoreSensitive
import TonSwift
import TonTransport

public final class WalletImportController {
    private let activeWalletService: ActiveWalletsService
    private let currencyService: CurrencyService

    init(
        activeWalletService: ActiveWalletsService,
        currencyService: CurrencyService
    ) {
        self.activeWalletService = activeWalletService
        self.currencyService = currencyService
    }

    public func findActiveWallets(
        mnemonic: CoreMnemonic,
        network: Network,
        checkHistory: Bool
    ) async throws -> [ActiveWalletModel] {
        let keyPair = try mnemonic.toKeyPair()
        let currency = (try? currencyService.getActiveCurrency()) ?? .USD
        return try await activeWalletService.loadActiveWallets(
            publicKey: keyPair.publicKey,
            network: network,
            currency: currency,
            checkHistory: checkHistory
        )
    }

    public func findActiveWallets(
        publicKey: TonSwift.PublicKey,
        network: Network,
        checkHistory: Bool
    ) async throws -> [ActiveWalletModel] {
        let currency = (try? currencyService.getActiveCurrency()) ?? .USD
        return try await activeWalletService.loadActiveWallets(
            publicKey: publicKey,
            network: network,
            currency: currency,
            checkHistory: checkHistory
        )
    }

    public func findActiveWallets(
        accounts: [(id: String, address: Address, revision: WalletContractVersion)],
        network: Network,
        checkHistory: Bool
    ) async throws -> [ActiveWalletModel] {
        let currency = (try? currencyService.getActiveCurrency()) ?? .USD
        return try await activeWalletService.loadActiveWallets(
            accounts: accounts,
            network: network,
            currency: currency,
            checkHistory: checkHistory
        )
    }
}
