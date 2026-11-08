import Foundation
import TonSwift

public protocol EncryptedCommentService {
    func decryptComment(payload: EncryptedCommentPayload, wallet: Wallet, passcode: String) async throws -> String?
}

final class EncryptedCommentServiceImplementation: EncryptedCommentService {
    private let mnemonicAccess: MnemonicAccess

    init(mnemonicAccess: MnemonicAccess) {
        self.mnemonicAccess = mnemonicAccess
    }

    func decryptComment(payload: EncryptedCommentPayload, wallet: Wallet, passcode: String) async throws -> String? {
        let mnemonic = try await mnemonicAccess.getMnemonic(
            wallet: wallet,
            passcode: passcode
        )
        let keyPair = try mnemonic.toKeyPair()

        return try CommentDecryptor(
            privateKey: keyPair.privateKey,
            publicKey: keyPair.publicKey,
            cipherText: payload.encryptedComment.cipherText,
            senderAddress: payload.senderAddress
        ).decrypt()
    }
}
