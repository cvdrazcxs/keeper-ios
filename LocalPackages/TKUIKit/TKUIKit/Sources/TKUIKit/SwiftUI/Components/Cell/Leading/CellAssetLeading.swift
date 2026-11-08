import SwiftUI

public struct CellAssetLeading<Content: View>: View {
    private let content: Content

    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(
                width: Layout.contentSize.width,
                height: Layout.contentSize.height
            )
            .padding(
                Layout.insets
            )
    }
}

extension CellAssetLeading {
    enum Layout {
        static var insets: EdgeInsets {
            EdgeInsets(
                top: 16,
                leading: 16,
                bottom: 16,
                trailing: 0
            )
        }

        static var contentSize: CGSize {
            CGSize(
                width: 44,
                height: 44
            )
        }
    }
}
