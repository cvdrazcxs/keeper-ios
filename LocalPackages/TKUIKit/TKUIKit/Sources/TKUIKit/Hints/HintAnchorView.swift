import SwiftUI
import UIKit

final class HintAnchorView: UIView {
    var onLayout: ((UIView) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        notifyIfReady()
    }

    func notifyIfReady() {
        guard window != nil, bounds.width > 0, bounds.height > 0 else { return }
        onLayout?(self)
    }
}
