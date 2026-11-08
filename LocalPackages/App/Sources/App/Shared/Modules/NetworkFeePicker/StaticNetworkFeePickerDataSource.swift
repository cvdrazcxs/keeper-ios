@MainActor
struct StaticNetworkFeePickerDataSource {
    private let _items: [NetworkFeePickerItem]
    private var _content: NetworkFeePickerContent {
        .uncategorized(dataSource: self)
    }

    init(items: [NetworkFeePickerItem]) {
        _items = items
    }
}

extension StaticNetworkFeePickerDataSource: NetworkFeePickerDataSource {
    var content: NetworkFeePickerContent? {
        _content
    }

    func loadContent() async -> NetworkFeePickerContent {
        _content
    }
}

extension StaticNetworkFeePickerDataSource: NetworkFeePickerItemsDataSource {
    var items: [NetworkFeePickerItem] {
        _items
    }
}
