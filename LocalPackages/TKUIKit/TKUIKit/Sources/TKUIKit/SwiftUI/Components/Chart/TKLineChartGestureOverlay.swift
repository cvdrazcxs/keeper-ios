import SwiftUI
import UIKit

enum TKLineChartGestureDirection {
    static func isHorizontal(translation: CGPoint) -> Bool {
        abs(translation.x) > abs(translation.y)
    }
}

struct TKLineChartGestureOverlay: UIViewRepresentable {
    let minimumPressDuration: TimeInterval
    let isEnabled: Bool
    let onSelectionBegan: (CGPoint) -> Void
    let onSelectionChanged: (CGPoint) -> Void
    let onSelectionEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isEnabled: isEnabled,
            onSelectionBegan: onSelectionBegan,
            onSelectionChanged: onSelectionChanged,
            onSelectionEnded: onSelectionEnded
        )
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = isEnabled

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPressGesture(_:))
        )
        longPressGestureRecognizer.minimumPressDuration = minimumPressDuration
        longPressGestureRecognizer.cancelsTouchesInView = false
        longPressGestureRecognizer.delegate = context.coordinator

        let panGestureRecognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePanGesture(_:))
        )
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = context.coordinator

        view.addGestureRecognizer(longPressGestureRecognizer)
        view.addGestureRecognizer(panGestureRecognizer)

        context.coordinator.attach(
            longPressGestureRecognizer: longPressGestureRecognizer,
            panGestureRecognizer: panGestureRecognizer
        )

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.isUserInteractionEnabled = isEnabled
        context.coordinator.update(
            isEnabled: isEnabled,
            onSelectionBegan: onSelectionBegan,
            onSelectionChanged: onSelectionChanged,
            onSelectionEnded: onSelectionEnded
        )
    }
}

extension TKLineChartGestureOverlay {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private var isEnabled: Bool
        private var onSelectionBegan: (CGPoint) -> Void
        private var onSelectionChanged: (CGPoint) -> Void
        private var onSelectionEnded: () -> Void

        private weak var longPressGestureRecognizer: UILongPressGestureRecognizer?
        private weak var panGestureRecognizer: UIPanGestureRecognizer?
        private var isLongPressActive = false

        init(
            isEnabled: Bool,
            onSelectionBegan: @escaping (CGPoint) -> Void,
            onSelectionChanged: @escaping (CGPoint) -> Void,
            onSelectionEnded: @escaping () -> Void
        ) {
            self.isEnabled = isEnabled
            self.onSelectionBegan = onSelectionBegan
            self.onSelectionChanged = onSelectionChanged
            self.onSelectionEnded = onSelectionEnded
        }

        func attach(
            longPressGestureRecognizer: UILongPressGestureRecognizer,
            panGestureRecognizer: UIPanGestureRecognizer
        ) {
            self.longPressGestureRecognizer = longPressGestureRecognizer
            self.panGestureRecognizer = panGestureRecognizer
            applyEnabledState()
        }

        func update(
            isEnabled: Bool,
            onSelectionBegan: @escaping (CGPoint) -> Void,
            onSelectionChanged: @escaping (CGPoint) -> Void,
            onSelectionEnded: @escaping () -> Void
        ) {
            if !isEnabled {
                finishSelectionIfNeeded()
            }

            self.isEnabled = isEnabled
            self.onSelectionBegan = onSelectionBegan
            self.onSelectionChanged = onSelectionChanged
            self.onSelectionEnded = onSelectionEnded
            applyEnabledState()
        }

        @objc
        func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)

            switch gestureRecognizer.state {
            case .began:
                isLongPressActive = true
                onSelectionBegan(location)
            case .ended, .cancelled, .failed:
                finishSelectionIfNeeded()
            default:
                break
            }
        }

        @objc
        func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
            guard isLongPressActive else {
                return
            }

            let location = gestureRecognizer.location(in: gestureRecognizer.view)

            switch gestureRecognizer.state {
            case .began, .changed:
                onSelectionChanged(location)
            case .cancelled, .failed:
                finishSelectionIfNeeded()
            default:
                break
            }
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard isEnabled else {
                return false
            }

            guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }

            guard isLongPressActive else {
                return false
            }

            return TKLineChartGestureDirection.isHorizontal(
                translation: panGestureRecognizer.velocity(in: panGestureRecognizer.view)
            )
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard
                let longPressGestureRecognizer,
                let panGestureRecognizer
            else {
                return false
            }

            let recognizers = [gestureRecognizer, otherGestureRecognizer]
            return recognizers.contains(longPressGestureRecognizer)
                && recognizers.contains(panGestureRecognizer)
        }

        private func applyEnabledState() {
            longPressGestureRecognizer?.isEnabled = isEnabled
            panGestureRecognizer?.isEnabled = isEnabled
        }

        private func finishSelectionIfNeeded() {
            guard isLongPressActive else {
                return
            }

            isLongPressActive = false
            onSelectionEnded()
        }
    }
}
