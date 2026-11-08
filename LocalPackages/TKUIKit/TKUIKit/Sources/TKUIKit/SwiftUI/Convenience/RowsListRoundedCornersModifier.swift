import SwiftUI

private struct RowsListRoundedCornersModifier: ViewModifier {
    var index: Int
    var total: Int
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .roundBottomIfNeeded(for: index, total: total, radius: radius)
            .roundTopIfNeeded(for: index, total: total, radius: radius)
    }
}

private extension View {
    @ViewBuilder
    func roundTopIfNeeded(for index: Int, total: Int, radius: CGFloat) -> some View {
        if index == 0 {
            self
                .clipShape(
                    RoundedRectExt(
                        radius: radius,
                        corners: [.topLeft, .topRight]
                    )
                )
        } else {
            self
        }
    }

    @ViewBuilder
    func roundBottomIfNeeded(for index: Int, total: Int, radius: CGFloat) -> some View {
        if index + 1 == total {
            self
                .clipShape(
                    RoundedRectExt(
                        radius: radius,
                        corners: [.bottomLeft, .bottomRight]
                    )
                )
        } else {
            self
        }
    }
}

public extension View {
    func roundIfNeeded(
        index: Int,
        total: Int,
        radius: CGFloat
    ) -> some View {
        modifier(
            RowsListRoundedCornersModifier(
                index: index,
                total: total,
                radius: radius
            )
        )
    }
}
