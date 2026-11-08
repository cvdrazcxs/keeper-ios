import UIKit

public final class TKOutsideBorderImageView: UIView {
    public struct Configuration: Hashable {
        public let image: TKImage
        public let imageSize: CGSize
        public let borderWidth: CGFloat
        public let borderColor: UIColor

        public init(
            image: TKImage,
            imageSize: CGSize,
            borderWidth: CGFloat,
            borderColor: UIColor
        ) {
            self.image = image
            self.imageSize = imageSize
            self.borderWidth = borderWidth
            self.borderColor = borderColor
        }

        static let empty = Configuration(
            image: .image(nil),
            imageSize: .zero,
            borderWidth: .zero,
            borderColor: .clear
        )
    }

    public var configuration = Configuration.empty {
        didSet {
            didUpdateConfiguration()
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    private let iconView = TKImageView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let contentFrame = CGRect(
            x: configuration.borderWidth,
            y: configuration.borderWidth,
            width: configuration.imageSize.width,
            height: configuration.imageSize.height
        )

        iconView.frame = contentFrame
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let border = configuration.borderWidth * 2
        return CGSize(
            width: configuration.imageSize.width + border,
            height: configuration.imageSize.height + border
        )
    }

    public func prepareForReuse() {
        iconView.prepareForReuse()
    }

    private func setup() {
        addSubview(iconView)
        didUpdateConfiguration()
    }

    private func didUpdateConfiguration() {
        backgroundColor = configuration.borderColor
        iconView.configure(
            model: TKImageView.Model(
                image: configuration.image,
                size: .size(configuration.imageSize),
                corners: .circle
            )
        )

        iconView.layer.cornerRadius = configuration.imageSize.height / 2
        iconView.layer.masksToBounds = true

        let border = configuration.borderWidth * 2
        layer.cornerRadius = (configuration.imageSize.width + border) / 2
        layer.masksToBounds = true
    }
}
