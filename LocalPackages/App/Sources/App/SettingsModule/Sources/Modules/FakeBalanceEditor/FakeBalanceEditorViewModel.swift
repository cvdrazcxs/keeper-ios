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

    var didRequestClose: (() -> Void)?

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

        tokenOptions = buildOptions()
        selectedTokenID = selectedOptionID(
            options: tokenOptions,
            savedSymbol: appSettings.fakeBalanceSymbol
        )
        amountText = appSettings.fakeBalanceAmount ?? ""
    }

    func reload() {
        let options = buildOptions()
        guard options.map(\.id) != tokenOptions.map(\.id) else { return }
        tokenOptions = options
        selectedTokenID = selectedOptionID(options: options, savedSymbol: currentSymbol)
    }

    func select(_ option: TokenOption) {
        selectedTokenID = option.id
    }

    var selectedSymbol: String {
        tokenOptions.first(where: { $0.id == selectedTokenID })?.symbol ?? ""
    }

    var canConfirm: Bool {
        parseAmount() != nil
    }

    func confirm() {
        guard
            let amount = parseAmount(),
            let id = selectedTokenID,
            let option = tokenOptions.first(where: { $0.id == id })
        else {
            return
        }
        appSettings.fakeBalanceAmount = amountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        appSettings.fakeBalanceSymbol = option.symbol
        appSettings.isFakeBalanceEnabled = true
        didRequestClose?()
    }

    private var currentSymbol: String? {
        tokenOptions.first(where: { $0.id == selectedTokenID })?.symbol ?? appSettings.fakeBalanceSymbol
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

    private func selectedOptionID(
        options: [TokenOption],
        savedSymbol: String?
    ) -> String? {
        if let savedSymbol, let saved = options.first(where: { $0.symbol == savedSymbol }) {
            return saved.id
        }
        return options.first?.id
    }

    private func parseAmount() -> Decimal? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
}
