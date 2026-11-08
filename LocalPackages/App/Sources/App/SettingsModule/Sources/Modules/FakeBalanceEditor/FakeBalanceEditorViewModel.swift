import Foundation
import KeeperCore
import SwiftUI
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
        var options: [TokenOption] = []
        if let balance = managedBalanceStore.state[wallet]?.balance {
            if let tonItem = balance.tonItems.first {
                options.append(
                    TokenOption(
                        id: "ton",
                        symbol: TonInfo.symbol,
                        name: tonItem.title,
                        imageURL: nil
                    )
                )
            }
            if balance.tronUSDTItem != nil {
                options.append(
                    TokenOption(
                        id: "tron_usdt",
                        symbol: USDT.symbol,
                        name: "USDT (TRON)",
                        imageURL: USDT.imageURL
                    )
                )
            }
            if balance.tronTRXItem != nil {
                options.append(
                    TokenOption(
                        id: "tron_trx",
                        symbol: TRX.symbol,
                        name: "TRX (TRON)",
                        imageURL: nil
                    )
                )
            }
            for jettonItem in balance.jettonItems {
                let info = jettonItem.jetton.jettonInfo
                options.append(
                    TokenOption(
                        id: info.address.toRaw(),
                        symbol: info.symbol,
                        name: info.name,
                        imageURL: info.imageURL
                    )
                )
            }
        }
        if !options.contains(where: { $0.id == "ton" }) {
            options.insert(
                TokenOption(id: "ton", symbol: TonInfo.symbol, name: TonInfo.symbol, imageURL: nil),
                at: 0
            )
        }
        return options
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
