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
        /// Display chain ("ton"/"tron", nil for catalog picks) — keeps
        /// "USDT" TRC20 and "USD₮" TON as separate fakes.
        let chain: String?
    }

    let title = FakeBalanceStrings.fakeBalance

    @Published private(set) var tokenOptions: [TokenOption] = []
    @Published var amountText = ""
    @Published private(set) var selectedTokenID: String?
    @Published private(set) var externalOption: TokenOption?
    @Published private(set) var fakeItems: [FakeBalanceItem] = []

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

        // Neutral defaults before touching instance methods (Swift forbids
        // using self until every stored property is initialized).
        tokenOptions = []
        amountText = ""
        selectedTokenID = nil
        externalOption = nil
        fakeItems = []

        fakeItems = appSettings.fakeBalanceItems
        tokenOptions = buildOptions()
        applySelection(for: fakeItems.first)
    }

    func reload() {
        let options = buildOptions()
        guard options.map(\.id) != tokenOptions.map(\.id) else { return }
        tokenOptions = options
        if externalOption == nil,
           let current = selectedTokenID,
           !options.contains(where: { $0.id == current }) {
            selectedTokenID = options.first?.id
            amountText = tokenOptions.first.map { savedAmountText(for: $0) } ?? ""
        }
    }

    func select(_ option: TokenOption) {
        externalOption = nil
        selectedTokenID = option.id
        amountText = savedAmountText(for: option)
    }

    /// Fork: token picked from the full multichain catalog (SOL, ETH, TRUMP…)
    /// — kept as an "external" option with its own symbol/name/logo.
    func setExternalToken(symbol: String, name: String, imageURL: URL?) {
        let resolvedSymbol = symbol.isEmpty ? name : symbol
        let option = TokenOption(
            id: "external",
            symbol: resolvedSymbol,
            name: name,
            imageURL: imageURL,
            chain: nil
        )
        externalOption = option
        selectedTokenID = nil
        amountText = savedAmountText(for: option)
    }

    /// Fork: upserts the fake amount of the selected token. Amounts of other
    /// faked tokens are kept — several coins can be faked at once.
    func confirm() {
        guard
            let amount = parseAmount(),
            let option = selectedOption
        else {
            return
        }
        let item = FakeBalanceItem(
            symbol: option.symbol,
            amount: amountText
                .replacingOccurrences(of: ",", with: ".")
                .trimmingCharacters(in: .whitespaces),
            name: option.name,
            imageURLString: option.imageURL?.absoluteString,
            chain: option.chain
        )
        var items = appSettings.fakeBalanceItems
        let normalized = FakeBalanceState.normalizedSymbol(option.symbol)
        let tag = FakeBalanceState.normalizedChain(option.chain)
        // Chain-aware upsert: a "tron" fake replaces the "tron" fake and any
        // legacy untagged fake of the same symbol, but keeps a "ton" one.
        items.removeAll {
            FakeBalanceState.normalizedSymbol($0.symbol) == normalized
                && (FakeBalanceState.normalizedChain($0.chain) == tag
                    || (tag != nil && FakeBalanceState.normalizedChain($0.chain) == nil))
        }
        items.insert(item, at: 0)
        appSettings.fakeBalanceItems = items
        appSettings.isFakeBalanceEnabled = true
        fakeItems = items
        didRequestClose?()
    }

    /// Fork: clears every faked token; the master toggle stays as is.
    func resetAll() {
        appSettings.fakeBalanceItems = []
        fakeItems = []
        amountText = ""
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

    /// Saved fake amount for the token — shown as a badge in the list.
    func fakeAmountText(for option: TokenOption) -> String? {
        let amount = savedAmountText(for: option)
        return amount.isEmpty ? nil : amount
    }

    var hasAnyFakes: Bool {
        !fakeItems.isEmpty
    }

    // MARK: - Private

    private func applySelection(for savedItem: FakeBalanceItem?) {
        guard let savedItem else {
            selectedTokenID = tokenOptions.first?.id
            amountText = ""
            return
        }
        let normalized = FakeBalanceState.normalizedSymbol(savedItem.symbol)
        let savedChain = FakeBalanceState.normalizedChain(savedItem.chain)
        // Prefer the option of the same chain, then any symbol match, then a
        // catalog-style entry that carries the saved (possibly tagged) fake.
        if let matched = tokenOptions.first(where: {
            FakeBalanceState.normalizedSymbol($0.symbol) == normalized
                && FakeBalanceState.chainCompatible(
                    fakeChain: savedChain,
                    assetChain: $0.chain
                )
                && (savedChain != nil || FakeBalanceState.normalizedChain($0.chain) == nil)
        }) {
            selectedTokenID = matched.id
        } else if let anyMatch = tokenOptions.first(where: {
            FakeBalanceState.normalizedSymbol($0.symbol) == normalized
        }) {
            selectedTokenID = anyMatch.id
        } else if !normalized.isEmpty {
            externalOption = TokenOption(
                id: "external",
                symbol: savedItem.symbol,
                name: savedItem.name ?? savedItem.symbol,
                imageURL: savedItem.imageURLString.flatMap { URL(string: $0) },
                chain: savedItem.chain
            )
        }
        if selectedTokenID == nil, externalOption == nil {
            selectedTokenID = tokenOptions.first?.id
        }
        amountText = savedItem.amount
    }

    private func savedAmountText(for option: TokenOption) -> String {
        fakeDisplayState
            .fakeItem(matchingAssetSymbol: option.symbol, chainTag: option.chain)?
            .amount ?? ""
    }

    /// One matching rule everywhere: rows, badges and amount prefill go
    /// through FakeBalanceState so a "tron" fake never touches a "ton" row.
    private var fakeDisplayState: FakeBalanceState {
        FakeBalanceState(isEnabled: true, items: fakeItems)
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
                option = TokenOption(id: "ton", symbol: TonInfo.symbol, name: tonItem.title, imageURL: nil, chain: "ton")
                order = 0
            case .tronUSDT:
                option = TokenOption(id: "tron_usdt", symbol: USDT.symbol, name: "USDT (TRON)", imageURL: USDT.imageURL, chain: "tron")
                order = 1
            case .tronTRX:
                option = TokenOption(id: "tron_trx", symbol: TRX.symbol, name: "TRX (TRON)", imageURL: nil, chain: "tron")
                order = 2
            case let .jetton(jettonItem):
                let info = jettonItem.jetton.jettonInfo
                option = TokenOption(
                    id: info.address.toRaw(),
                    symbol: jettonSymbol(info),
                    name: info.name,
                    imageURL: info.imageURL,
                    chain: "ton"
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
        TokenOption(id: "ton", symbol: TonInfo.symbol, name: TonInfo.name, imageURL: nil, chain: "ton")
    }

    private func parseAmount() -> Decimal? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
}
