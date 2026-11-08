import UIKit

open class BasicViewController: UIViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        TKThemeManager.shared.theme.themeAppaearance.statusBarStyle(for: traitCollection.userInterfaceStyle)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.fixInteractivePopGestureRecognizer(delegate: self)
    }
}

extension BasicViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is PanDirectionGestureRecognizer else {
            return true
        }

        return navigationController?.canBeginSwipeBackGesture(gestureRecognizer) ?? false
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer is PanDirectionGestureRecognizer
    }
}
