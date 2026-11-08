import Foundation

enum BatteryRechargeItem: String, CaseIterable {
    case large
    case medium
    case small

    var chargesCount: Int {
        switch self {
        case .large:
            return 2000
        case .medium:
            return 1250
        case .small:
            return 750
        }
    }

    var batteryPercent: CGFloat {
        switch self {
        case .large:
            return 1
        case .medium:
            return 0.5
        case .small:
            return 0.3
        }
    }
}
