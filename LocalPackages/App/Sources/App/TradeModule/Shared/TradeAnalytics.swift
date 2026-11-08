import TKCore

enum TradeFlowAnalyticsSource: String {
    case walletScreen = "wallet_screen"
    case jettonScreen = "jetton_screen"
    case deepLink = "deep_link"
    case qrCode = "qr_code"
    case tabBar = "tab_bar"

    var tradeStarted: TradeStarted.From {
        switch self {
        case .walletScreen:
            .walletScreen
        case .jettonScreen:
            .jettonScreen
        case .deepLink:
            .deepLink
        case .qrCode:
            .qrCode
        case .tabBar:
            .tabBar
        }
    }

    var tradeClickAsset: TradeClickAsset.From {
        switch self {
        case .walletScreen:
            .walletScreen
        case .jettonScreen:
            .jettonScreen
        case .deepLink:
            .deepLink
        case .qrCode:
            .qrCode
        case .tabBar:
            .tabBar
        }
    }

    var tradeSearch: TradeSearch.From {
        switch self {
        case .walletScreen:
            .walletScreen
        case .jettonScreen:
            .jettonScreen
        case .deepLink:
            .deepLink
        case .qrCode:
            .qrCode
        case .tabBar:
            .tabBar
        }
    }

    var tradeSearchClick: TradeSearchClick.From {
        switch self {
        case .walletScreen:
            .walletScreen
        case .jettonScreen:
            .jettonScreen
        case .deepLink:
            .deepLink
        case .qrCode:
            .qrCode
        case .tabBar:
            .tabBar
        }
    }

    var assetViewSource: AssetViewAnalyticsSource {
        switch self {
        case .walletScreen:
            .walletScreen
        case .deepLink:
            .deepLink
        case .qrCode:
            .qrCode
        case .tabBar, .jettonScreen:
            .tradeScreen
        }
    }
}

enum AssetViewAnalyticsSource: String {
    case walletScreen = "wallet_screen"
    case deepLink = "deep_link"
    case qrCode = "qr_code"
    case tradeScreen = "trade_screen"

    var assetView: AssetView.From {
        switch self {
        case .walletScreen:
            .walletScreen
        case .deepLink:
            .deepLink
        case .qrCode:
            .qrCode
        case .tradeScreen:
            .tradeScreen
        }
    }
}
