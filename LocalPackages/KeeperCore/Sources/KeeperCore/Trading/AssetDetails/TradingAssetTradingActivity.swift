import Foundation

public struct TradingAssetTradingActivity: Equatable, Sendable {
    public var volumeText: String
    public var volumeChangeText: String?
    public var buyText: String
    public var sellText: String
    public var buyFraction: Double
}
