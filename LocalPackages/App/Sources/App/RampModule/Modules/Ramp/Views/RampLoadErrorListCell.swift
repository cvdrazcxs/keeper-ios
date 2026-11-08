import TKLocalize
import TKUIKit
import UIKit

final class RampLoadErrorListCell: TKCollectionViewListCell {
    var didTapRetry: (() -> Void)? {
        didSet {
            applyConfiguration()
        }
    }

    private let bannerContent = BannerContentView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Background.content
        layer.cornerRadius = 16

        let highlightView = UIView()
        highlightView.backgroundColor = .Background.highlighted
        self.highlightView = highlightView

        setContentView(bannerContent)
        listCellContentViewPadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        applyConfiguration()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didUpdateCellOrderInSection() {
        super.didUpdateCellOrderInSection()
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bannerContent.prepareForReuse()
    }

    private func applyConfiguration() {
        bannerContent.configure(didTapRetry: didTapRetry)
    }
}

private extension RampLoadErrorListCell {
    final class BannerContentView: UIView {
        private let iconView = TKListItemIconView()
        private let titleView = TKListItemTitleView()
        private let retryButton = TKButton()

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            addSubview(iconView)
            addSubview(titleView)
            addSubview(retryButton)
            configure(didTapRetry: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(didTapRetry: (() -> Void)?) {
            iconView.configuration = TKListItemIconView.Configuration(
                content: .image(
                    TKImageView.Model(
                        image: .image(
                            .TKUIKit.Icons.Size32.exclamationmarkCircle.withRenderingMode(.alwaysTemplate)
                        ),
                        tintColor: .Icon.secondary,
                        size: .size(CGSize(width: 24, height: 24)),
                        corners: .circle
                    )
                ),
                alignment: .center,
                cornerRadius: 22,
                backgroundColor: .Background.contentTint,
                size: CGSize(width: 44, height: 44)
            )

            titleView.configuration = TKListItemTitleView.Configuration(
                title: TKLocales.Ramp.List.loadErrorBannerTitle.withTextStyle(.label1, color: .Text.primary),
                numberOfLines: 0
            )

            let title: String?
            let hPadding: CGFloat
            if let window, window.bounds.width <= 375 {
                title = nil
                hPadding = 8
            } else {
                title = TKLocales.Ramp.List.loadErrorBannerButton
                hPadding = 16
            }

            var buttonConfiguration = TKButton.Configuration.actionButtonConfiguration(category: .secondary, size: .small)
            buttonConfiguration.content = TKButton.Configuration.Content(
                title: title.map { .plainString($0) },
                icon: .TKUIKit.Icons.Size16.refresh
            )
            buttonConfiguration.spacing = 10
            buttonConfiguration.iconPosition = .left
            buttonConfiguration.action = didTapRetry
            buttonConfiguration.contentPadding = UIEdgeInsets(top: 8, left: hPadding, bottom: 8, right: hPadding)
            buttonConfiguration.backgroundColors = [
                .normal: .Button.tertiaryBackground,
                .highlighted: .Button.tertiaryBackgroundHighlighted,
            ]
            retryButton.configuration = buttonConfiguration
        }

        func prepareForReuse() {
            iconView.prepareForReuse()
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            let iconSize = iconView.sizeThatFits(.zero)
            let iconSpace = iconSize.width + Constants.iconTitleSpacing

            let retrySize = retryButton.sizeThatFits(
                CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height)
            )
            let titleWidth = max(0, bounds.width - iconSpace - Constants.titleRetrySpacing - retrySize.width)

            iconView.frame = CGRect(origin: .zero, size: iconSize)

            let titleHeight = titleView.sizeThatFits(CGSize(width: titleWidth, height: 0)).height
            titleView.frame = CGRect(
                x: iconSpace,
                y: 0,
                width: titleWidth,
                height: titleHeight
            )

            let contentHeight = max(iconSize.height, titleHeight)
            retryButton.frame = CGRect(
                x: iconSpace + titleWidth + Constants.titleRetrySpacing,
                y: (contentHeight - retrySize.height) * 0.5,
                width: retrySize.width,
                height: retrySize.height
            )
        }

        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let width = size.width
            let iconSize = iconView.sizeThatFits(.zero)
            let iconSpace = iconSize.width + Constants.iconTitleSpacing

            let retryWidth = retryButton.sizeThatFits(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            ).width
            let titleWidth = max(0, width - iconSpace - Constants.titleRetrySpacing - retryWidth)
            let titleHeight = titleView.sizeThatFits(CGSize(width: titleWidth, height: 0)).height

            let height = max(iconSize.height, titleHeight)
            return CGSize(width: width, height: height)
        }

        override var intrinsicContentSize: CGSize {
            CGSize(width: UIView.noIntrinsicMetric, height: sizeThatFits(CGSize(width: bounds.width, height: 0)).height)
        }
    }

    enum Constants {
        static let iconTitleSpacing: CGFloat = 16
        static let titleRetrySpacing: CGFloat = 12
    }
}

typealias RampLoadErrorListCellRegistration = UICollectionView.CellRegistration<RampLoadErrorListCell, Void>

extension RampLoadErrorListCellRegistration {
    static func registration(collectionView: UICollectionView) -> RampLoadErrorListCellRegistration {
        RampLoadErrorListCellRegistration { _, _, _ in }
    }
}
