import Foundation
import TKUIKit

public final class AppSettings {
    private let userDefaults: UserDefaults

    package init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func isDappOpenWarningDoNotShow(_ host: String) -> Bool {
        let key = String.dappOpenWarningDoNotShowKey + "_\(host)"
        return userDefaults.bool(forKey: key)
    }

    public func setIsDappOpenWarningDoNotShow(_ host: String, doNotShow: Bool) {
        let key = String.dappOpenWarningDoNotShowKey + "_\(host)"
        userDefaults.set(doNotShow, forKey: key)
    }

    public var isDecryptCommentWarningDoNotShow: Bool {
        get {
            userDefaults.bool(forKey: .decryptCommentDoNotShowKey)
        }
        set {
            userDefaults.setValue(newValue, forKey: .decryptCommentDoNotShowKey)
        }
    }

    public var fcmToken: String? {
        get {
            userDefaults.string(forKey: .fcmToken)
        }
        set {
            userDefaults.setValue(newValue, forKey: .fcmToken)
        }
    }

    /// Last multichain push state accepted by the backend: the token and the full wallet id
    /// set. `nil` wallet ids means "never synced", so a device that has no notifications on
    /// never has to authenticate just to send an empty subscription.
    public var multichainPushToken: String? {
        get {
            userDefaults.string(forKey: .multichainPushToken)
        }
        set {
            userDefaults.setValue(newValue, forKey: .multichainPushToken)
        }
    }

    /// Device the push subscription below belongs to: a rotated device id invalidates it.
    public var multichainPushDeviceId: String? {
        get {
            userDefaults.string(forKey: .multichainPushDeviceId)
        }
        set {
            userDefaults.setValue(newValue, forKey: .multichainPushDeviceId)
        }
    }

    public var multichainPushWalletIds: [String]? {
        get {
            userDefaults.stringArray(forKey: .multichainPushWalletIds)
        }
        set {
            userDefaults.setValue(newValue, forKey: .multichainPushWalletIds)
        }
    }

    public var multichainPushLocale: String? {
        get {
            userDefaults.string(forKey: .multichainPushLocale)
        }
        set {
            userDefaults.setValue(newValue, forKey: .multichainPushLocale)
        }
    }

    public var addressCopyCount: Int {
        get {
            userDefaults.integer(forKey: .addressCopyCount)
        }
        set {
            userDefaults.setValue(newValue, forKey: .addressCopyCount)
        }
    }

    public var firstLaunchDate: Date? {
        get {
            guard let timestamp = userDefaults.value(forKey: .firstLaunchTimestamp) as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            userDefaults.setValue(newValue?.timeIntervalSince1970, forKey: .firstLaunchTimestamp)
        }
    }

    public var isPerpsStoryAccepted: Bool {
        get {
            userDefaults.bool(forKey: .perpsStoryAccepted)
        }
        set {
            userDefaults.setValue(newValue, forKey: .perpsStoryAccepted)
        }
    }

    /// Fork feature "fake balance": when enabled the wallet header renders the
    /// configured fake amount instead of the real balance. Purely visual.
    public var isFakeBalanceEnabled: Bool {
        get {
            userDefaults.bool(forKey: .fakeBalanceEnabled)
        }
        set {
            userDefaults.setValue(newValue, forKey: .fakeBalanceEnabled)
        }
    }

    /// Fork feature "fake balance": each faked token is stored as an item so
    /// several coins can be faked at once. Newest entry first. Migrates the
    /// legacy single-fake storage on first read.
    public var fakeBalanceItems: [FakeBalanceItem] {
        get {
            if let data = userDefaults.data(forKey: .fakeBalanceItems) {
                return (try? JSONDecoder().decode([FakeBalanceItem].self, from: data)) ?? []
            }
            guard
                let amount = userDefaults.string(forKey: .fakeBalanceAmount),
                let symbol = userDefaults.string(forKey: .fakeBalanceSymbol)
            else {
                return []
            }
            let migrated = [FakeBalanceItem(
                symbol: symbol,
                amount: amount,
                name: userDefaults.string(forKey: .fakeBalanceName),
                imageURLString: userDefaults.string(forKey: .fakeBalanceImageURLString)
            )]
            if let data = try? JSONEncoder().encode(migrated) {
                userDefaults.setValue(data, forKey: .fakeBalanceItems)
            }
            return migrated
        }
        set {
            let data = (try? JSONEncoder().encode(newValue)) ?? Data()
            userDefaults.setValue(data, forKey: .fakeBalanceItems)
            userDefaults.removeObject(forKey: .fakeBalanceAmount)
            userDefaults.removeObject(forKey: .fakeBalanceSymbol)
            userDefaults.removeObject(forKey: .fakeBalanceName)
            userDefaults.removeObject(forKey: .fakeBalanceImageURLString)
        }
    }

    public let dappHostWhiteList: [String] = ["dapp.aeon.xyz"]
}

/// Fork feature "fake balance": one faked token entry.
public struct FakeBalanceItem: Codable, Hashable, Sendable {
    public let symbol: String
    public let amount: String
    public let name: String?
    public let imageURLString: String?
    /// Display chain the fake was configured against ("ton"/"tron"/nil).
    /// When set, the fake only covers assets of that chain — "USDT" on TRON
    /// and "USD₮" on TON stay independent fakes.
    public let chain: String?

    public init(
        symbol: String,
        amount: String,
        name: String? = nil,
        imageURLString: String? = nil,
        chain: String? = nil
    ) {
        self.symbol = symbol
        self.amount = amount
        self.name = name
        self.imageURLString = imageURLString
        self.chain = chain
    }
}

private extension String {
    static let dappOpenWarningDoNotShowKey = "dapp_open_warning_do_not_show_key"
    static let decryptCommentDoNotShowKey = "decrypt_comment_do_not_show_warning"
    static let fcmToken = "fcm_token"
    static let multichainPushToken = "multichain_push_token"
    static let multichainPushDeviceId = "multichain_push_device_id"
    static let multichainPushWalletIds = "multichain_push_wallet_ids"
    static let multichainPushLocale = "multichain_push_locale"
    static let addressCopyCount = "address_copy_count"
    static let firstLaunchTimestamp = "first_launch_timestamp"
    static let perpsStoryAccepted = "perps_story_accepted"
    static let fakeBalanceEnabled = "fake_balance_enabled"
    static let fakeBalanceAmount = "fake_balance_amount"
    static let fakeBalanceSymbol = "fake_balance_symbol"
    static let fakeBalanceName = "fake_balance_name"
    static let fakeBalanceImageURLString = "fake_balance_image_url"
    static let fakeBalanceItems = "fake_balance_items"
}
