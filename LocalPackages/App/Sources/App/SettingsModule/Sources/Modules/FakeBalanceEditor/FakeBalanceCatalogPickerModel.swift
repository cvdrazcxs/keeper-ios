import Foundation
import KeeperCore

/// Fork: catalog-only `TokenPickerV2Model` — searches the app's full multichain
/// token catalog (TON jettons, SOL/ETH chains, meme coins) without tying the
/// search to this wallet's balances.
final class FakeBalanceCatalogPickerModel: TokenPickerV2Model {
    private let multichainService: MultichainService
    private let currencyStore: CurrencyStore

    private var sort: MultichainAssetSearchSort = .marketCap

    init(
        multichainService: MultichainService,
        currencyStore: CurrencyStore
    ) {
        self.multichainService = multichainService
        self.currencyStore = currencyStore
    }

    var initialState: TokenPickerV2ModelState {
        TokenPickerV2ModelState(
            filters: [.all],
            displayMode: .includingMarketData,
            initialFilter: .all
        )
    }

    var showsCatalogSortControl: Bool { false }

    var catalogSearchSort: MultichainAssetSearchSort { sort }

    func setCatalogSearchSort(_ sort: MultichainAssetSearchSort) {
        self.sort = sort
    }

    func loadAssets(
        query: String?,
        filter: TokenPickerV2ChainFilter,
        limit: Int,
        cursor: String?
    ) async throws(MultichainServiceError) -> TokenPickerLoadResult {
        var currencies = [currencyStore.state.code.lowercased()]
        if currencyStore.state != .defaultCurrency {
            currencies.append(Currency.defaultCurrency.code.lowercased())
        }
        let page = try await multichainService.searchAssets(
            currencies: currencies,
            chain: filter.chain,
            search: query,
            sort: sort,
            limit: limit,
            cursor: cursor
        )
        return TokenPickerLoadResult(assets: page.assets, nextCursor: page.nextCursor)
    }
}
