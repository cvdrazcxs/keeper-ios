@testable import KeeperCore
import XCTest

final class OnRampLayoutFilteringTests: XCTestCase {
    func test_filtering_removes_all_assets_when_cash_or_crypto_is_unavailable() {
        let layout = makeLayout(cryptoAssets: [makeTONAsset()])

        let filtered = layout.filteredByCashOrCryptoAvailability(isAvailable: false)

        XCTAssertTrue(filtered.items.isEmpty)
    }

    func test_filtering_removes_tron_assets_and_network_methods() {
        let layout = makeLayout(cryptoAssets: [
            makeTONAsset(cryptoMethods: [
                .init(
                    symbol: "USDT",
                    assetId: "usdt-ton",
                    address: nil,
                    network: "ton",
                    networkName: "TON",
                    networkImage: "https://example.com/ton.png",
                    image: "https://example.com/usdt.png",
                    decimals: 6,
                    stablecoin: true,
                    fee: nil,
                    minAmount: nil,
                    providers: []
                ),
                .init(
                    symbol: "USDT",
                    assetId: "usdt-trc20",
                    address: nil,
                    network: "trc20",
                    networkName: "TRON",
                    networkImage: "https://example.com/tron.png",
                    image: "https://example.com/usdt.png",
                    decimals: 6,
                    stablecoin: true,
                    fee: nil,
                    minAmount: nil,
                    providers: []
                ),
            ]),
            OnRampLayoutToken(
                symbol: "USDT",
                assetId: "usdt-trc20",
                address: nil,
                network: "trc20",
                networkName: "TRON",
                networkImage: "https://example.com/tron.png",
                image: "https://example.com/usdt.png",
                decimals: 6,
                stablecoin: true,
                cashMethods: [],
                cryptoMethods: []
            ),
        ])

        let filtered = layout.filteredByTRC20Availability(isAvailable: false)

        let flatAssets = filtered.items.flatMap { $0.assets ?? [] }
        XCTAssertEqual(flatAssets.count, 1)
        XCTAssertEqual(flatAssets.first?.network.lowercased(), "ton")
        XCTAssertEqual(flatAssets.first?.cryptoMethods.count, 1)
        XCTAssertEqual(flatAssets.first?.cryptoMethods.first?.network.lowercased(), "ton")
    }

    private func makeLayout(cryptoAssets tokens: [OnRampLayoutToken]) -> OnRampLayout {
        OnRampLayout(items: [
            OnRampLayoutItem(
                type: .crypto,
                title: "",
                itemDescription: "",
                image: "",
                preferredCurrency: nil,
                assets: tokens
            ),
        ])
    }

    private func makeTONAsset(cryptoMethods: [OnRampLayoutCryptoMethod] = []) -> OnRampLayoutToken {
        OnRampLayoutToken(
            symbol: "USDT",
            assetId: "usdt-ton",
            address: nil,
            network: "ton",
            networkName: "TON",
            networkImage: "https://example.com/ton.png",
            image: "https://example.com/usdt.png",
            decimals: 6,
            stablecoin: true,
            cashMethods: [],
            cryptoMethods: cryptoMethods
        )
    }
}
