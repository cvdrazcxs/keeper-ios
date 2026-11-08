import Foundation

/// Fork feature strings for the fake balance UI. Bilingual (ru/en) based on the
/// app's preferred localization, without touching the TKLocalize codegen.
enum FakeBalanceStrings {
    static var isRussian: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("ru") == true
    }

    static var showFakeBalance: String {
        isRussian ? "Показывать фейк баланс" : "Show fake balance"
    }

    static var fakeBalance: String {
        isRussian ? "Фейк баланс" : "Fake balance"
    }

    static var tokenSectionTitle: String {
        isRussian ? "МОНЕТА ИЗ КОШЕЛЬКА" : "WALLET COIN"
    }

    static var allCoinsButton: String {
        isRussian ? "Искать любую монету (SOL, ETH, TRUMP…)" : "Search any coin (SOL, ETH, TRUMP…)"
    }

    static var allCoinsTitle: String {
        isRussian ? "Все монеты" : "All coins"
    }

    static var amountSectionTitle: String {
        isRussian ? "СУММА" : "AMOUNT"
    }

    static var amountPlaceholder: String {
        isRussian ? "Введите сумму" : "Enter amount"
    }

    static var caption: String {
        isRussian
            ? "Можно накрутить сразу несколько монет — они суммируются в шапке и в строках. Только отображение, реальные средства не трогаются."
            : "Fake as many coins as you like — they add up in the header total and rows. Display only, real funds stay untouched."
    }

    static var resetAll: String {
        isRussian ? "Сбросить всё" : "Reset all"
    }

    static var confirm: String {
        isRussian ? "Подтвердить" : "Confirm"
    }
}
