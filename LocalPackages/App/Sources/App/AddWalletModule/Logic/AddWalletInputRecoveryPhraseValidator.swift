import Foundation
import KeeperCoreComponents
import KeeperCoreSensitive
import TKScreenKit
import TonSwift

struct AddWalletInputRecoveryPhraseValidator: TKInputRecoveryPhraseValidator {
    func validateWord(_ word: String) -> Bool {
        Mnemonic.words.contains(word)
    }

    func validatePhrase(_ phrase: [String]) -> RecoveryPhraseValidationResult {
        let derivation: DerivationType = .guessByWords(phrase)
        switch derivation {
        case .ton:
            return .valid
        default:
            break
        }
        if Mnemonic.isMultiAccountSeed(mnemonicArray: phrase) {
            return .multiaccount
        }
        return derivation.isUnknown ? .unknown : .valid
    }
}
