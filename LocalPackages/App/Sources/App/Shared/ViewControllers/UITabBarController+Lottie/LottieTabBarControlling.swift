import Foundation

@MainActor
protocol LottieTabBarControlling: NSObject {
    func uninstall()
    func playAnimation(at index: Int)
}

private final class DenyTapOnSelectedItem: NSObject, LottieTabBarControlling {
    private let implementation: LottieTabBarControlling
    private var latestPlayedItem: Int?

    init(implementation: LottieTabBarControlling) {
        self.implementation = implementation
    }

    func uninstall() {
        implementation.uninstall()
        latestPlayedItem = nil
    }

    func playAnimation(at index: Int) {
        guard index != latestPlayedItem else {
            return
        }
        latestPlayedItem = index
        implementation.playAnimation(at: index)
    }
}

extension LottieTabBarControlling {
    func denyingTapOnSelectedItem() -> LottieTabBarControlling {
        DenyTapOnSelectedItem(implementation: self)
    }
}
