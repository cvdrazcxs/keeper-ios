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
        if let fake = mapFakeBalanceAmountIfEnabled(currency: totalBalance?.currency) {
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

    /// Fork: the enabled fake balance renders exactly like the real fiat
    /// total — the amount with the display-currency symbol ("$ 500",
    /// "2 500 ₽"), never a token suffix. Several faked tokens are summed up.
    func mapFakeBalanceAmountIfEnabled(currency: Currency?) -> BalanceViewContent.Balance? {
        guard
            let appSettings,
            appSettings.isFakeBalanceEnabled,
            let currency,
            let total = FakeBalanceState.current(from: appSettings).displayTotalAmount
        else {
            return nil
        }
        return mapFiatBalanceAmount(amount: total, currency: currency)
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
