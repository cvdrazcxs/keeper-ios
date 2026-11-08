import Foundation
import KeeperCore
import SwiftUI
import TKCore
import TronSwift

@MainActor
final class FakeBalanceEditorViewModel: ObservableObject {
    struct TokenOption: Identifiable {
        let id: String
        let symbol: String
        let name: String
        let imageURL: URL?
    }

    let title = FakeBalanceStrings.fakeBalance

    @Published private(set) var tokenOptions: [TokenOption] = []
    @Published var amountText: String
    @Published private(set) var selectedTokenID: String?
    @Published private(set) var externalOption: TokenOption?

    var didRequestClose: (() -> Void)?
    var didRequestOpenCatalogPicker: (() -> Void)?

    private let wallet: Wallet
    private let managedBalanceStore: ManagedBalanceStore
    private let appSettings: TKCore.AppSettings

    init(
        wallet: Wallet,
        managedBalanceStore: ManagedBalanceStore,
        appSettings: TKCore.AppSettings
    ) {
        self.wallet = wallet
        self.managedBalanceStore = managedBalanceStore
        self.appSettings = appSettings

        // Initialize all stored properties before calling instance methods
        // (Swift forbids using self until every stored property is initialized).
        tokenOptions = []
        amountText = ""
        selectedTokenID = nil
        externalOption = nil

        tokenOptions = buildOptions()
        amountText = appSettings.fakeBalanceAmount ?? ""
        if let savedSymbol = appSettings.fakeBalanceSymbol,
           let saved = tokenOptions.first(where: { $0.symbol == savedSymbol }) {
            selectedTokenID = saved.id
        } else if let savedSymbol = appSettings.fakeBalanceSymbol {
            externalOption = TokenOption(
                id: "external",
                symbol: savedSymbol,
                name: appSettings.fakeBalanceName ?? savedSymbol,
                imageURL: appSettings.fakeBalanceImageURLString.flatMap { URL(string: $0) }
            )
        } else {
            selectedTokenID = tokenOptions.first?.id
        }
    }

    func reload() {
        let options = buildOptions()
        guard options.map(\.id) != tokenOptions.map(\.id) else { return }
        tokenOptions = options
        if externalOption == nil,
           let current = selectedTokenID,
           !options.contains(where: { $0.id == current }) {
            selectedTokenID = options.first?.id
        }
    }

    func select(_ option: TokenOption) {
        externalOption = nil
        selectedTokenID = option.id
    }

    /// Fork: token picked from the full multichain catalog (SOL, ETH, TRUMP…)
    /// — kept as an "external" option with its own symbol/name/logo.
    func setExternalToken(symbol: String, name: String, imageURL: URL?) {
        selectedTokenID = nil
        externalOption = TokenOption(
            id: "external",
            symbol: symbol.isEmpty ? name : symbol,
            name: name,
            imageURL: imageURL
        )
    }

    var selectedSymbol: String {
        if let externalOption {
            return externalOption.symbol
        }
        return tokenOptions.first(where: { $0.id == selectedTokenID })?.symbol ?? ""
    }

    var canConfirm: Bool {
        parseAmount() != nil && selectedOption != nil
    }

    func confirm() {
        guard
            let amount = parseAmount(),
            let option = selectedOption
        else {
            return
        }
        appSettings.fakeBalanceAmount = amountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        appSettings.fakeBalanceSymbol = option.symbol
        appSettings.fakeBalanceName = option.name
        appSettings.fakeBalanceImageURLString = option.imageURL?.absoluteString
        appSettings.isFakeBalanceEnabled = true
        didRequestClose?()
    }

    private var selectedOption: TokenOption? {
        if let externalOption {
            return externalOption
        }
        return tokenOptions.first { $0.id == selectedTokenID }
    }

    private func buildOptions() -> [TokenOption] {
        guard let balance = managedBalanceStore.state[wallet]?.balance else {
            return [fallbackTonOption]
        }

        var results: [(option: TokenOption, order: Int)] = []

        func append(_ option: TokenOption, order: Int) {
            guard !results.contains(where: { $0.option.id == option.id }) else { return }
            results.append((option, order))
        }

        for item in balance.pinnedItems + balance.unpinnedItems {
            let option: TokenOption
            let order: Int
            switch item {
            case let .ton(tonItem):
                option = TokenOption(id: "ton", symbol: TonInfo.symbol, name: tonItem.title, imageURL: nil)
                order = 0
            case .tronUSDT:
                option = TokenOption(id: "tron_usdt", symbol: USDT.symbol, name: "USDT (TRON)", imageURL: USDT.imageURL)
                order = 1
            case .tronTRX:
                option = TokenOption(id: "tron_trx", symbol: TRX.symbol, name: "TRX (TRON)", imageURL: nil)
                order = 2
            case let .jetton(jettonItem):
                let info = jettonItem.jetton.jettonInfo
                option = TokenOption(
                    id: info.address.toRaw(),
                    symbol: jettonSymbol(info),
                    name: info.name,
                    imageURL: info.imageURL
                )
                order = 3
            case .staking, .ethena:
                continue
            }
            append(option, order: order)
        }

        guard !results.isEmpty else { return [fallbackTonOption] }
        return results
            .sorted { lhs, rhs in
                lhs.order != rhs.order ? lhs.order < rhs.order : lhs.option.symbol < rhs.option.symbol
            }
            .map(\.option)
    }

    /// JettonInfo.symbol is optional and may be empty; fall back to the name.
    private func jettonSymbol(_ info: JettonInfo) -> String {
        if let symbol = info.symbol, !symbol.isEmpty { return symbol }
        return info.name
    }

    private var fallbackTonOption: TokenOption {
        TokenOption(id: "ton", symbol: TonInfo.symbol, name: TonInfo.name, imageURL: nil)
    }

    private func parseAmount() -> Decimal? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
}
