import SwiftUI
import UIKit

struct TKHintSourceViewResolver: UIViewRepresentable {
    let onResolve: (UIView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = HintAnchorView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.onLayout = onResolve
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? HintAnchorView)?.onLayout = onResolve
        (uiView as? HintAnchorView)?.notifyIfReady()
    }
}
