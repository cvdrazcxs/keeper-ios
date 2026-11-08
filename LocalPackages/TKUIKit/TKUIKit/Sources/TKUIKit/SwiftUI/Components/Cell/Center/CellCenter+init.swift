import SwiftUI

public extension CellCenter {
    init(
        @ViewBuilder primaryRow: () -> PrimaryRow,
        @ViewBuilder secondaryRow: () -> SecondaryRow,
        contentInsets: (inout EdgeInsets) -> Void = { _ in }
    ) {
        self.init(
            primaryRow: primaryRow(),
            secondaryRow: secondaryRow(),
            contentInsets: contentInsets
        )
    }
}

public extension CellCenter where SecondaryRow == EmptyView {
    init(
        @ViewBuilder primaryRow: () -> PrimaryRow,
        contentInsets: (inout EdgeInsets) -> Void = { _ in }
    ) {
        self.init(
            primaryRow: primaryRow(),
            secondaryRow: EmptyView(),
            contentInsets: contentInsets
        )
    }
}
