import BigInt
import KeeperCore
import SwiftUI
import TKCore
import TKLocalize
import TKUIKit
import UIKit

struct WalletBalanceHeaderMapper {
    private let amountFormatter: AmountFormatter
    private let dateFormatter: DateFormatter
    private let appSettings: TKCore.AppSettings?

    init(
        amountFormatter: AmountFormatter,
        dateFormatter: DateFormatter,
        appSettings: TKCore.AppSettings? = nil
    ) {
        self.amountFormatter = amountFormatter
        self.dateFormatter = dateFormatter
        self.appSettings = appSettings
    }

    func makeUpdatedDate(_ date: Date) -> String {
        dateFormatter.dateFormat = "d MMM HH:mm"
        return dateFormatter.string(from: date)
    }

    func mapTotalBalanceAmount(totalBalance: TotalBalance?) -> BalanceViewContent.Balance {
        if let fake = mapFakeBalanceAmountIfEnabled() {
            return fake
        }

        guard let totalBalance else {
            return BalanceViewContent.Balance(text: "-")
        }

        return mapFiatBalanceAmount(
            amount: totalBalance.amount,
            currency: totalBalance.currency
        )
    }

    /// Fork: when the fake balance is enabled and configured, returns the
    /// fake amount content, otherwise nil.
    func mapFakeBalanceAmountIfEnabled() -> BalanceViewContent.Balance? {
        guard let fakeBalance else { return nil }
        return mapTokenAmountBalance(amount: fakeBalance.amount, symbol: fakeBalance.symbol)
    }

    func mapFiatBalanceAmount(
        amount: Decimal,
        currency: Currency
    ) -> BalanceViewContent.Balance {
        BalanceViewContent.Balance(
            amount: mapBalanceHeaderAmountFormat(
                amountFormatter.formatBalanceHeaderAmount(
                    decimal: amount,
                    accessory: .fiat(currency)
                )
            )
        )
    }

    /// Fork: enabled fake balance renders as a token-style amount, e.g. "1 000 000 USDT",
    /// using the exact same typography as the real balance.
    func mapTokenAmountBalance(
        amount: Decimal,
        symbol: String
    ) -> BalanceViewContent.Balance {
        BalanceViewContent.Balance(
            amount: mapBalanceHeaderAmountFormat(
                amountFormatter.formatBalanceHeaderAmount(
                    decimal: amount,
                    accessory: .tokenSymbol(symbol)
                )
            )
        )
    }

    private var fakeBalance: (amount: Decimal, symbol: String)? {
        guard
            let appSettings,
            appSettings.isFakeBalanceEnabled,
            let amountText = appSettings.fakeBalanceAmount,
            let symbol = appSettings.fakeBalanceSymbol,
            let amount = Decimal(
                string: amountText.replacingOccurrences(of: ",", with: "."),
                locale: Locale(identifier: "en_US_POSIX")
            )
        else {
            return nil
        }
        return (amount, symbol)
    }

    func mapBalanceHeaderAmountFormat(
        _ format: BalanceHeaderAmountFormat
    ) -> BalanceViewContent.Balance.Amount {
        BalanceViewContent.Balance.Amount(
            leadingText: format.leadingAccessory,
            trailingText: format.trailingAccessory,
            textParts: format.numberParts.map { part in
                BalanceViewContent.Balance.Amount.TextPart(
                    text: part.text,
                    role: mapRole(part.role)
                )
            },
            textSize: mapTextSize(format.textSize),
            tooltipText: format.tooltipText,
            accessibilityText: format.fullText
        )
    }

    private func mapRole(
        _ role: BalanceHeaderAmountFormat.NumberPart.Role
    ) -> BalanceViewContent.Balance.Amount.TextPart.Role {
        switch role {
        case .primary:
            return .primary
        case .fraction:
            return .fraction
        }
    }

    private func mapTextSize(
        _ textSize: BalanceHeaderAmountFormat.TextSize
    ) -> BalanceViewContent.Balance.Amount.TextSize {
        switch textSize {
        case .regular:
            return .regular
        case .reduced:
            return .reduced
        }
    }
}
