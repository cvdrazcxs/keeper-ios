import Foundation
import KeeperCore

final class RampPickerAssetModel: RampPickerModel {
    var didUpdateState: ((RampPickerState?) -> Void)?

    private let assets: [RampAsset]
    private let selectedId: String?

    init(assets: [RampAsset], selectedId: String? = nil) {
        self.assets = assets
        self.selectedId = selectedId
    }

    func getState() -> RampPickerState? {
        RampPickerState(
            mode: .asset(assets: assets),
            scrollToSelected: false
        )
    }
}
