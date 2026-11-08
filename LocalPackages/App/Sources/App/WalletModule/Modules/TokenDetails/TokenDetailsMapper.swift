import BigInt
import Foundation
import KeeperCore

struct TokenDetailsMapper {
    private let amountFormatter: AmountFormatter
    private let rateConverter: RateConverter

    init(
        amountFormatter: AmountFormatter,
        rateConverter: RateConverter
    ) {
        self.amountFormatter = amountFormatter
        self.rateConverter = rateConverter
    }

    func mapTonBalance(tonBalance: ProcessedBalanceTonItem?, currency: Currency?) -> (
        tokenAmount: String,
        convertedAmount: String?
    ) {
        guard let amount = tonBalance?.amount else {
            return ("0", nil)
        }
        let bigUIntAmount = BigUInt(amount)

        let formattedAmount = amountFormatter.format(
            amount: bigUIntAmount,
            fractionDigits: TonInfo.fractionDigits,
            accessory: .tokenSymbol(TonInfo.symbol),
            isNegative: false,
            style: .exactValue
        )
        var converted: String?
        if let currency, let convertedAmount = tonBalance?.converted {
            converted = amountFormatter.format(
                decimal: convertedAmount,
                accessory: .fiat(currency),
                style: .fiatBalance
            )
        }

        return (formattedAmount, converted)
    }

    func mapBalance(
        amount: BigUInt,
        converted: Decimal,
        fractionDigits: Int,
        symbol: String,
        currency: Currency
    ) -> (tokenAmount: String, convertedAmount: String?) {
        let amount = amountFormatter.format(
            amount: amount,
            fractionDigits: fractionDigits,
            accessory: .tokenSymbol(symbol),
            isNegative: false,
            style: .regular
        )
        let convertedFormatted = amountFormatter.format(
            decimal: converted,
            accessory: .fiat(currency),
            style: .fiatBalance
        )
        return (amount, convertedFormatted)
    }

    func mapJettonBalance(
        jettonBalance: ProcessedBalanceJettonItem?,
        currency: Currency?
    ) -> (tokenAmount: String, convertedAmount: String?) {
        guard let jettonBalance else {
            return ("0", nil)
        }

        let amount = amountFormatter.format(
            amount: jettonBalance.amount,
            fractionDigits: jettonBalance.jetton.jettonInfo.fractionDigits,
            accessory: jettonBalance.jetton.jettonInfo.symbol.flatMap { .tokenSymbol($0) } ?? .none,
            isNegative: false,
            style: .exactValue
        )

        let convertedAmount = amountFormatter.format(
            decimal: jettonBalance.converted,
            accessory: currency.flatMap { .fiat($0) } ?? .none,
            style: .fiatBalance
        )
        return (amount, convertedAmount)
    }

    func mapEphenaBalance(balance: ProcessedBalanceEthenaItem?) -> (tokenAmount: String, convertedAmount: String?) {
        let amount = amountFormatter.format(
            amount: balance?.amount ?? 0,
            fractionDigits: USDe.fractionDigits,
            accessory: .tokenSymbol(USDe.symbol),
            isNegative: false,
            style: .exactValue
        )

        let convertedAmount = amountFormatter.format(
            decimal: balance?.converted ?? 0,
            accessory: .fiat((balance?.currency ?? .USD)),
            style: .fiatBalance
        )
        return (amount, convertedAmount)
    }
}
