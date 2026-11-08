import Foundation

public struct TradingAssetListSnapshot: Equatable, Sendable {
    public var generatedAt: Date
    public var currency: Currency
    public var assets: [TradingAsset]
    public var nextCursor: String?

    public var hasNextPage: Bool {
        nextCursor != nil
    }
}

extension TradingAssetListSnapshot {
    func merged(with nextPage: TradingAssetListSnapshot) -> TradingAssetListSnapshot {
        var mergedAssets = assets
        var indexesById = Dictionary(
            uniqueKeysWithValues: mergedAssets.enumerated().map { ($0.element.id, $0.offset) }
        )

        for asset in nextPage.assets {
            if let index = indexesById[asset.id] {
                mergedAssets[index] = asset
            } else {
                indexesById[asset.id] = mergedAssets.count
                mergedAssets.append(asset)
            }
        }

        return TradingAssetListSnapshot(
            generatedAt: max(generatedAt, nextPage.generatedAt),
            currency: nextPage.currency,
            assets: mergedAssets,
            nextCursor: nextPage.nextCursor
        )
    }
}
