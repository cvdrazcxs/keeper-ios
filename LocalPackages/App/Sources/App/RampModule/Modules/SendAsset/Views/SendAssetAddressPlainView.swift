import SnapKit
import TKLocalize
import TKUIKit
import UIKit

final class SendAssetAddressPlainView: UIView {
    struct Model {
        let title: String
        let address: String
    }

    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let qrButton = UIButton()
    private let copyButton = TKButton(
        configuration: .actionButtonConfiguration(
            category: .primary,
            size: .medium
        )
    )

    private lazy var buttonsStackView = UIStackView(arrangedSubviews: [copyButton, qrButton])

    var onQrButtonTap: (() -> Void)?
    var onCopyButtonTap: (() -> Void)? {
        didSet {
            copyButton.configuration.action = onCopyButtonTap
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Model) {
        titleLabel.attributedText = model.title.withTextStyle(.body2, color: .Text.secondary, alignment: .center)
        let displayAddress = Self.format(address: model.address)
        addressLabel.attributedText = displayAddress.withTextStyle(.body1Mono, color: .Text.primary, alignment: .center)
    }

    private static func format(address: String) -> String {
        guard !address.isEmpty else { return address }
        let mid = address.count / 2
        return address.prefix(mid) + "\n" + address.suffix(address.count - mid)
    }
}

private extension SendAssetAddressPlainView {
    func setup() {
        backgroundColor = .Background.content
        layer.cornerRadius = 16

        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        addressLabel.numberOfLines = 0
        addressLabel.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        addressLabel.textAlignment = .center
        addressLabel.setContentHuggingPriority(.required, for: .vertical)
        addressLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        copyButton.configuration.content = .init(
            title: .plainString(TKLocales.Ramp.Deposit.copyAddress),
            icon: .TKUIKit.Icons.Size16.copy
        )
        copyButton.configuration.iconPosition = .leftSticky

        qrButton.backgroundColor = .Background.contentTint
        qrButton.layer.cornerRadius = TKActionButtonSize.medium.height / 2
        qrButton.layer.masksToBounds = true
        qrButton.setImage(.TKUIKit.Icons.Size16.qrCode, for: .normal)
        qrButton.tintColor = .Icon.primary

        qrButton.addTarget(self, action: #selector(didTapQrButton), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(addressLabel)

        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 12
        buttonsStackView.alignment = .center
        addSubview(buttonsStackView)

        setupConstraints()
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self).inset(16)
        }

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalTo(self).inset(16)
        }

        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalTo(self).inset(16)
            make.height.equalTo(TKActionButtonSize.medium.height)
        }

        qrButton.snp.makeConstraints { make in
            make.size.equalTo(TKActionButtonSize.medium.height)
        }
    }

    @objc
    func didTapQrButton() {
        onQrButtonTap?()
    }
}
