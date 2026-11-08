import SwiftUI
import TKLocalize
import TKUIKit

struct TradeAssetDetailsAboutSectionView: View {
    let screen: TradeAssetDetailsScreenViewData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ListTitleView(
                config: .text(
                    TKLocales.Trade.AssetDetails.Sections.about
                )
            )
            TKExpandableTextView(
                text: screen.aboutParagraph,
                collapsedLineLimit: Layout.collapsedLineLimit,
                moreTitle: TKLocales.Actions.more
            )
        }
        .padding(.horizontal, Layout.horizontalPadding)
    }
}

private extension TradeAssetDetailsAboutSectionView {
    enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let collapsedLineLimit = 3
    }
}
