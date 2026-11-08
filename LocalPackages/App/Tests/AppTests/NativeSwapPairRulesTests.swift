@testable import App
import KeeperCore
import TonSwift
import XCTest

final class NativeSwapPairRulesTests: XCTestCase {
    func test_tokenizedStocksAreAllowedOnlyAgainstTonUSDT() {
        XCTAssertTrue(
            NativeSwapPairRules.isAllowed(
                fromToken: usdtToken(),
                toToken: tokenizedStockToken(),
                fromClassification: .crypto,
                toClassification: .stock
            )
        )

        XCTAssertFalse(
            NativeSwapPairRules.isAllowed(
                fromToken: .ton(.ton),
                toToken: tokenizedStockToken(),
                fromClassification: .crypto,
                toClassification: .stock
            )
        )

        XCTAssertFalse(
            NativeSwapPairRules.isAllowed(
                fromToken: cryptoJettonToken(),
                toToken: tokenizedStockToken(),
                fromClassification: .crypto,
                toClassification: .stock
            )
        )
    }

    func test_tokenizedEtfsAreAllowedOnlyAgainstTonUSDT() {
        XCTAssertTrue(
            NativeSwapPairRules.isAllowed(
                fromToken: tokenizedETFToken(),
                toToken: usdtToken(),
                fromClassification: .etf,
                toClassification: .crypto
            )
        )

        XCTAssertFalse(
            NativeSwapPairRules.isAllowed(
                fromToken: tokenizedETFToken(),
                toToken: .ton(.ton),
                fromClassification: .etf,
                toClassification: .crypto
            )
        )
    }

    func test_spyxCanBeTradedAgainstTonAndTonUSDT() {
        XCTAssertTrue(
            NativeSwapPairRules.isAllowed(
                fromToken: .ton(.ton),
                toToken: spyxToken(),
                fromClassification: .crypto,
                toClassification: .etf
            )
        )

        XCTAssertTrue(
            NativeSwapPairRules.isAllowed(
                fromToken: usdtToken(),
                toToken: spyxToken(),
                fromClassification: .crypto,
                toClassification: .etf
            )
        )

        XCTAssertFalse(
            NativeSwapPairRules.isAllowed(
                fromToken: cryptoJettonToken(),
                toToken: spyxToken(),
                fromClassification: .crypto,
                toClassification: .etf
            )
        )
    }

    func test_regularCryptoPairsAreUnrestricted() {
        XCTAssertTrue(
            NativeSwapPairRules.isAllowed(
                fromToken: .ton(.ton),
                toToken: cryptoJettonToken(),
                fromClassification: .crypto,
                toClassification: .crypto
            )
        )
    }

    func test_sameTokenPairIsNotAllowed() {
        XCTAssertFalse(
            NativeSwapPairRules.isAllowed(
                fromToken: .ton(.ton),
                toToken: .ton(.ton),
                fromClassification: .crypto,
                toClassification: .crypto
            )
        )

        XCTAssertFalse(
            NativeSwapPairRules.isAllowed(
                fromToken: usdtToken(),
                toToken: usdtToken(),
                fromClassification: .crypto,
                toClassification: .crypto
            )
        )
    }
}

private extension NativeSwapPairRulesTests {
    func usdtToken() -> KeeperCore.Token {
        jettonToken(address: JettonMasterAddress.tonUSDT, symbol: "USDT")
    }

    func spyxToken() -> KeeperCore.Token {
        jettonToken(address: JettonMasterAddress.SPYx, symbol: "SPYx")
    }

    func tokenizedStockToken() -> KeeperCore.Token {
        jettonToken(
            address: try! Address.parse("0:1000000000000000000000000000000000000000000000000000000000000000"),
            symbol: "TSLAx"
        )
    }

    func tokenizedETFToken() -> KeeperCore.Token {
        jettonToken(
            address: try! Address.parse("0:2000000000000000000000000000000000000000000000000000000000000000"),
            symbol: "QQQx"
        )
    }

    func cryptoJettonToken() -> KeeperCore.Token {
        jettonToken(
            address: try! Address.parse("0:3000000000000000000000000000000000000000000000000000000000000000"),
            symbol: "NOT"
        )
    }

    func jettonToken(address: Address, symbol: String) -> KeeperCore.Token {
        .ton(
            .jetton(
                JettonItem(
                    jettonInfo: JettonInfo(
                        isTransferable: true,
                        hasCustomPayload: false,
                        address: address,
                        fractionDigits: 9,
                        name: symbol,
                        symbol: symbol,
                        verification: .whitelist,
                        imageURL: nil
                    ),
                    walletAddress: nil
                )
            )
        )
    }
}
