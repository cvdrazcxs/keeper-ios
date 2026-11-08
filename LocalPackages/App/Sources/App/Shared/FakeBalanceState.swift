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
            .map { "\($0.symbol)|\($0.amount)|\($0.chain ?? "-")" }
            .sorted()
            .joined(separator: ";")
    }

    /// Fiat total of every fake: fake amount × the live unit price when one
    /// is resolvable (keeping the header equal to the token rows), else the
    /// raw amount. Displayed with the display-currency symbol.
    func displayTotalFiat(
        unitPriceResolver: ((_ item: FakeBalanceItem) -> Decimal?)?
    ) -> Decimal? {
        guard isEnabled, !items.isEmpty else { return nil }
        var total: Decimal?
        for item in items {
            guard let amount = Self.decimalAmount(ofText: item.amount) else { continue }
            let unitPrice = unitPriceResolver?(item)
            let value = unitPrice.map { amount * $0 } ?? amount
            total = (total ?? 0) + value
        }
        return total
    }

    /// The faked amount applying to the given asset row. Fakes configured
    /// with a chain tag cover only that chain ("USDT" TRC20 ≠ "USD₮" TON);
    /// untagged fakes (catalog picks, pre-migration entries) still match by
    /// normalized symbol on any chain.
    func fakeAmountDecimal(forAssetSymbol rawSymbol: String, chainTag chainRaw: String?) -> Decimal? {
        guard let item = fakeItem(matchingAssetSymbol: rawSymbol, chainTag: chainRaw) else { return nil }
        return Self.decimalAmount(ofText: item.amount)
    }

    /// The fake item that applies to the given asset row (nil = no fake).
    func fakeItem(matchingAssetSymbol rawSymbol: String, chainTag chainRaw: String?) -> FakeBalanceItem? {
        guard isEnabled else { return nil }
        let normalized = Self.normalizedSymbol(rawSymbol)
        guard !normalized.isEmpty else { return nil }
        let assetChain = Self.normalizedChain(chainRaw)

        var candidates = items.filter { Self.normalizedSymbol($0.symbol) == normalized }
        if let assetChain {
            if let exact = candidates.first(where: { Self.normalizedChain($0.chain) == assetChain }) {
                return exact
            }
            // Tagged fakes never leak to another chain; only untagged ones do.
            candidates = candidates.filter { Self.normalizedChain($0.chain) == nil }
        }
        return candidates.first
    }

    /// Normalized chain tag: lower-case trimmed token, or nil when untagged.
    static func normalizedChain(_ raw: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    /// True when a fake item applies to an asset of the given chain. Tagged
    /// fakes stick to their chain; untagged fakes (nil) cover any chain.
    static func chainCompatible(fakeChain: String?, assetChain: String?) -> Bool {
        guard let fake = normalizedChain(fakeChain) else { return true }
        guard let asset = normalizedChain(assetChain) else { return true }
        return fake == asset
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
