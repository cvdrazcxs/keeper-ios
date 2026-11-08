import KeeperCore
import TKUIKit

@MainActor
final class TradeAssetsListCategoryViewModel {
    private let category: TradingAssetCategory
    private let assetsListService: TradingAssetsListService
    private let amountFormatter: AmountFormatter
    private let signedAmountFormatter: AmountFormatter
    private let onWillPerformSearch: (String?) -> Void

    private var queryViewModels = [String: TradeAssetsListQueryViewModel]()

    init(
        category: TradingAssetCategory,
        assetsListService: TradingAssetsListService,
        amountFormatter: AmountFormatter,
        signedAmountFormatter: AmountFormatter,
        onWillPerformSearch: @escaping (String?) -> Void
    ) {
        self.category = category
        self.assetsListService = assetsListService
        self.amountFormatter = amountFormatter
        self.signedAmountFormatter = signedAmountFormatter
        self.onWillPerformSearch = onWillPerformSearch
    }

    func queryViewModel(for query: String?) -> TradeAssetsListQueryViewModel {
        let key = query ?? ""
        if let queryViewModel = queryViewModels[key] {
            return queryViewModel
        }

        let queryViewModel = TradeAssetsListQueryViewModel(
            query: query,
            category: category,
            assetsListService: assetsListService,
            amountFormatter: amountFormatter,
            signedAmountFormatter: signedAmountFormatter,
            onWillPerformSearch: { [onWillPerformSearch] in
                onWillPerformSearch(query)
            }
        )
        queryViewModels[key] = queryViewModel
        return queryViewModel
    }

    func disappeared() {
        queryViewModels.values.forEach { $0.disappeared() }
    }
}
