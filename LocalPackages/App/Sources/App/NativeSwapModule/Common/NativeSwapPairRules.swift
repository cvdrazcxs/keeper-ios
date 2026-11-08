import KeeperCore
import TonSwift

enum NativeSwapPairRules {
    static func isAllowed(
        fromToken: KeeperCore.Token,
        toToken: KeeperCore.Token,
        fromClassification: NativeSwapAssetClassification,
        toClassification: NativeSwapAssetClassification
    ) -> Bool {
        guard fromToken != toToken else {
            return false
        }

        let fromIsTokenized = fromClassification.isTokenized
        let toIsTokenized = toClassification.isTokenized

        guard fromIsTokenized || toIsTokenized else {
            return true
        }

        guard fromIsTokenized != toIsTokenized else {
            return false
        }

        let tokenizedToken = fromIsTokenized ? fromToken : toToken
        let counterpartToken = fromIsTokenized ? toToken : fromToken

        if tokenizedToken.isSPYx {
            return counterpartToken.isTON || counterpartToken.isTonUSDT
        }

        return counterpartToken.isTonUSDT
    }
}

extension KeeperCore.Token {
    var isTON: Bool {
        switch self {
        case .ton(.ton):
            return true
        case .ton(.jetton), .tron:
            return false
        }
    }

    var isTonUSDT: Bool {
        tonJettonAddress == JettonMasterAddress.tonUSDT
    }

    var isSPYx: Bool {
        tonJettonAddress == JettonMasterAddress.SPYx
    }

    var tonJettonAddress: Address? {
        switch self {
        case let .ton(.jetton(jettonItem)):
            return jettonItem.jettonInfo.address
        case .ton(.ton), .tron:
            return nil
        }
    }
}
