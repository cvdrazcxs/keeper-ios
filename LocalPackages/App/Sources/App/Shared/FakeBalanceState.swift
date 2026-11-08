import Foundation
import TKCore

/// Fork: snapshot of the fake-balance prank state, shared by the header
/// mapper and the token list view models. Display-only — nothing here
/// writes to wallet balances, history or real portfolio stores.
struct FakeBalanceState {
    let isEnabled: Bool
    let amountText: String
    let symbol: String
    let name: String?

    /// Reads the current prank configuration from settings.
    static func current(from settings: TKCore.AppSettings) -> FakeBalanceState {
        FakeBalanceState(
            isEnabled: settings.isFakeBalanceEnabled,
            amountText: settings.fakeBalanceAmount ?? "",
            symbol: settings.fakeBalanceSymbol ?? "",
            name: settings.fakeBalanceName
        )
    }

    /// Stable signature of the prank configuration, used to skip redundant
    /// presentation rebuilds when unrelated UserDefaults values change.
    static func renderKey(from settings: TKCore.AppSettings) -> String {
        [
            settings.isFakeBalanceEnabled ? "1" : "0",
            settings.fakeBalanceAmount ?? "",
            settings.fakeBalanceSymbol ?? "",
        ]
        .joined(separator: "|")
    }

    /// Parsed fake amount as entered by the user (accepts "," as decimal mark).
    var decimalAmount: Decimal? {
        Decimal(
            string: amountText.replacingOccurrences(of: ",", with: "."),
            locale: Locale(identifier: "en_US_POSIX")
        )
    }

    /// Aliases like "USD₮" and "USDT" (row title) must match.
    func matchesSymbol(_ rawSymbol: String) -> Bool {
        let normalized = Self.normalizedSymbol(rawSymbol)
        guard !normalized.isEmpty else { return false }
        return normalized == Self.normalizedSymbol(symbol)
    }

    private static func normalizedSymbol(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: nil)
            .replacingOccurrences(of: "₮", with: "T")
            .uppercased()
    }
}
