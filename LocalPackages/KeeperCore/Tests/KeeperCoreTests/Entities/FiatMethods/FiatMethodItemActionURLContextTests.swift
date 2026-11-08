@testable import KeeperCore
import TonSwift
import XCTest

final class FiatMethodItemActionURLContextTests: XCTestCase {
    func test_actionURLContext_mercuryoWithMixedCaseID_addsSignatureAndReplacesTransactionIdPlaceholder() async throws {
        let item = FiatMethodItem(
            id: "MeRcuRyO-buy",
            title: "Mercuryo",
            subtitle: nil,
            isDisabled: false,
            badge: nil,
            description: nil,
            iconURL: nil,
            actionButton: .init(
                title: "Buy",
                url: "https://example.com/purchase?widget_id={TX_ID}&address={ADDRESS}&from={CUR_FROM}&to={CUR_TO}"
            ),
            infoButtons: []
        )

        let walletAddress = try FriendlyAddress(
            address: Address.parse("EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c"),
            bounceable: true
        )

        let context = await item.actionURLContext(
            walletAddress: walletAddress,
            tronAddress: nil,
            currency: .USD,
            mercuryoParameters: .init(
                secret: "secret",
                ipProvider: { "127.0.0.1" }
            )
        )

        guard let context else {
            XCTFail("Expected action URL context")
            return
        }

        let absoluteString = context.url.absoluteString
        XCTAssertFalse(absoluteString.contains("{TX_ID}"))

        let components = try XCTUnwrap(URLComponents(url: context.url, resolvingAgainstBaseURL: false))
        let queryItems = components.queryItems ?? []

        let merchantTransactionId = queryItems.first { $0.name == "merchant_transaction_id" }?.value
        XCTAssertEqual(merchantTransactionId, context.transactionId?.uuidString)

        let signature = queryItems.first { $0.name == "signature" }?.value
        XCTAssertNotNil(signature)
        XCTAssertTrue(signature?.hasPrefix("v2:") == true)
    }

    func test_actionURLContext_mixedCaseSellId_usesSellCurrencyDirection() async throws {
        let item = FiatMethodItem(
            id: "MoOnPaY-SeLl",
            title: "MoonPay",
            subtitle: nil,
            isDisabled: false,
            badge: nil,
            description: nil,
            iconURL: nil,
            actionButton: .init(
                title: "Sell",
                url: "https://example.com/sell?from={CUR_FROM}&to={CUR_TO}"
            ),
            infoButtons: []
        )

        let walletAddress = try FriendlyAddress(
            address: Address.parse("EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c"),
            bounceable: true
        )

        let context = await item.actionURLContext(
            walletAddress: walletAddress,
            tronAddress: nil,
            currency: .USD,
            mercuryoParameters: .init(secret: nil, ipProvider: { nil })
        )

        let url = try XCTUnwrap(context?.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = components.queryItems ?? []

        XCTAssertEqual(queryItems.first { $0.name == "from" }?.value, "GRAM")
        XCTAssertEqual(queryItems.first { $0.name == "to" }?.value, "USD")
    }
}
