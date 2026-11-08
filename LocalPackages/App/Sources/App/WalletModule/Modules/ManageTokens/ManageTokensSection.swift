import Foundation
import KeeperCore
import TKLocalize
import TKUIKit

enum ManageTokensSection: Hashable {
    case pinned
    case allAssets

    var headerConfiguration: ManageTokensListSectionHeaderView.Configuration {
        let title: String
        switch self {
        case .allAssets:
            title = TKLocales.HomeScreenConfiguration.Sections.allAssets
        case .pinned:
            title = TKLocales.HomeScreenConfiguration.Sections.pinned
        }
        return ManageTokensListSectionHeaderView.Configuration(title: title)
    }
}

class ManageTokensListItem: Hashable {
    let identifier: String
    let canReorder: Bool
    let accessories: [TKListItemAccessory]

    static func == (lhs: ManageTokensListItem, rhs: ManageTokensListItem) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    init(
        identifier: String,
        canReorder: Bool,
        accessories: [TKListItemAccessory]
    ) {
        self.identifier = identifier
        self.canReorder = canReorder
        self.accessories = accessories
    }
}
