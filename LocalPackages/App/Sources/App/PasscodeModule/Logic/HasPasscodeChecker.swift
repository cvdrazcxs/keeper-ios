import KeeperCore
import TKLogging

protocol HasPasscodeChecker {
    var hasPasscode: Bool { get }
}

struct DefaultHasPasscodeChecker {
    private let mnemonicsAccess: MnemonicAccess
    private let keeperInfoRepository: KeeperInfoRepository

    init(
        mnemonicsAccess: MnemonicAccess,
        keeperInfoRepository: KeeperInfoRepository
    ) {
        self.mnemonicsAccess = mnemonicsAccess
        self.keeperInfoRepository = keeperInfoRepository
    }
}

extension DefaultHasPasscodeChecker: HasPasscodeChecker {
    var hasPasscode: Bool {
        let hasMnemonics = mnemonicsAccess.hasMnemonics()
        let hasRegularWallet: Bool
        do {
            hasRegularWallet = try keeperInfoRepository
                .getKeeperInfo()
                .wallets.map(\.kind)
                .contains(.regular)
        } catch {
            Log.w("failed to check if regular wallet exists due to error: \(error.localizedDescription)")
            hasRegularWallet = false
        }
        return hasMnemonics && hasRegularWallet
    }
}
