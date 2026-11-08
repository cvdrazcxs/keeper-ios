import Foundation
import TKCore

/// Fork: snapshot of the fake-balance prank, shared by the header mapper and
/// token list view models. Display-only — real balances are never written.
struct FakeBalanceState {
    let isEnabled: Bool
    let items: [FakeBalanceItem]

    static func current(from settings: TKCore.AppSettings) -> FakeBalanceState {
        FakeBalanceState(
            isEnabled: settings.isFakeBalanceEnabled,
            items: settings.fakeBalanceItems
        )
    }

    /// Stable signature of the prank configuration, used to skip redundant
    /// presentation rebuilds when unrelated UserDefaults values change.
    static func renderKey(from settings: TKCore.AppSettings) -> String {
        guard settings.isFakeBalanceEnabled else { return "off" }
        return "on|" + settings.fakeBalanceItems
            .map { "\($0.symbol)|\($0.amount)" }
            .sorted()
            .joined(separator: ";")
    }

    /// Sum of all fake amounts — the header shows it as the fiat total
    /// ("$ 500") with the selected display-currency symbol.
    var displayTotalAmount: Decimal? {
        var total: Decimal?
        for item in items {
            guard let amount = Self.decimalAmount(ofText: item.amount) else { continue }
            total = (total ?? 0) + amount
        }
        return total
    }

    /// The faked amount for a symbol, if any. One fake covers every chain
    /// where the symbol matches (aliases like "USD₮" and "USDT" are equal).
    func fakeAmountDecimal(forSymbol rawSymbol: String) -> Decimal? {
        guard isEnabled else { return nil }
        let normalized = Self.normalizedSymbol(rawSymbol)
        guard !normalized.isEmpty else { return nil }
        for item in items where Self.normalizedSymbol(item.symbol) == normalized {
            return Self.decimalAmount(ofText: item.amount)
        }
        return nil
    }

    /// "USD₮" and "USDT" must match; everything is upper-cased first.
    static func normalizedSymbol(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: nil)
            .replacingOccurrences(of: "₮", with: "T")
            .uppercased()
    }

    /// Parses "1 000,5" / "1000.5" — group separators are ignored.
    static func decimalAmount(ofText raw: String) -> Decimal? {
        let normalized = raw
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
}
