import SnapKit
import TKLocalize
import TKUIKit
import UIKit

final class SendAssetAddressMemoView: UIView {
    struct Model {
        let title: String
        let address: String
        let memoTitle: String
        let memo: String?
    }

    private let qrButton = TKButton(configuration: SendAssetAddressMemoView.iconOnlyConfiguration(icon: .TKUIKit.Icons.Size16.qrCode))
    private let addressCopyButton = TKButton(configuration: SendAssetAddressMemoView.iconOnlyConfiguration(icon: .TKUIKit.Icons.Size16.copy))
    private let memoCopyButton = TKButton(configuration: SendAssetAddressMemoView.iconOnlyConfiguration(icon: .TKUIKit.Icons.Size16.copy))

    private let addressRow: SendAssetDetailRowView
    private let memoRow: SendAssetDetailRowView

    private let copyDetailsButton = TKButton(
        configuration: .actionButtonConfiguration(
            category: .primary,
            size: .medium
        )
    )
    private let contentStackView = UIStackView()

    var onQrButtonTap: (() -> Void)?
    var onCopyAddressButtonTap: (() -> Void)?
    var onCopyMemoButtonTap: (() -> Void)?
    var onCopyDetailsButtonTap: (() -> Void)? {
        didSet {
            copyDetailsButton.configuration.action = onCopyDetailsButtonTap
        }
    }

    override init(frame: CGRect) {
        addressRow = SendAssetDetailRowView(trailingButtons: [qrButton, addressCopyButton])
        memoRow = SendAssetDetailRowView(trailingButtons: [memoCopyButton])
        super.init(frame: frame)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Model) {
        let displayAddress = Self.format(address: model.address)
        addressRow.configure(
            title: model.title,
            value: displayAddress,
            badgeConfiguration: nil
        )

        let hasMemo = (model.memo?.isEmpty == false)
        memoRow.isHidden = !hasMemo
        if hasMemo, let memo = model.memo {
            memoRow.configure(
                title: model.memoTitle,
                value: memo,
                badgeConfiguration: .accentTag(text: TKLocales.Ramp.Deposit.memoRequiredBadge, color: .Accent.orange)
            )
        }
    }

    private static func format(address: String) -> String {
        guard !address.isEmpty else { return address }
        let mid = address.count / 2
        return address.prefix(mid) + "\n" + address.suffix(address.count - mid)
    }
}

private extension SendAssetAddressMemoView {
    func setup() {
        backgroundColor = .Background.content
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous

        copyDetailsButton.configuration.content = .init(
            title: .plainString(TKLocales.Ramp.Deposit.copyDetails),
            icon: .TKUIKit.Icons.Size16.copy
        )
        copyDetailsButton.configuration.iconPosition = .leftSticky

        bindIconButtons()

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.addArrangedSubview(addressRow)
        contentStackView.addArrangedSubview(memoRow)
        contentStackView.addArrangedSubview(copyDetailsButton)

        addSubview(contentStackView)

        setupConstraints()
    }

    func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(16)
        }

        copyDetailsButton.snp.makeConstraints { make in
            make.height.equalTo(TKActionButtonSize.medium.height)
        }
    }

    func bindIconButtons() {
        var qrConfig = qrButton.configuration
        qrConfig.action = { [weak self] in self?.onQrButtonTap?() }
        qrButton.configuration = qrConfig

        var addressCopyConfig = addressCopyButton.configuration
        addressCopyConfig.action = { [weak self] in self?.onCopyAddressButtonTap?() }
        addressCopyButton.configuration = addressCopyConfig

        var memoCopyConfig = memoCopyButton.configuration
        memoCopyConfig.action = { [weak self] in self?.onCopyMemoButtonTap?() }
        memoCopyButton.configuration = memoCopyConfig
    }

    static func iconOnlyConfiguration(icon: UIImage) -> TKButton.Configuration {
        TKButton.Configuration(
            content: .init(icon: icon),
            contentPadding: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6),
            padding: .zero,
            iconTintColor: .Icon.secondary,
            backgroundColors: [
                .normal: .clear,
                .highlighted: .clear,
                .disabled: .clear,
            ],
            contentAlpha: [.normal: 1, .disabled: 0.48, .highlighted: 0.64],
            cornerRadius: 0,
            action: nil
        )
    }
}

private final class SendAssetDetailRowView: UIView {
    private let titleLabel = UILabel()
    private let badgeView = TKTagView()
    private let headerStackView = UIStackView()
    private let valueLabel = UILabel()
    private let actionsStackView = UIStackView()
    private let valueRowStackView = UIStackView()
    private let rootStackView = UIStackView()

    init(trailingButtons: [TKButton]) {
        super.init(frame: .zero)
        setup(trailingButtons: trailingButtons)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, value: String, badgeConfiguration: TKTagView.Configuration?) {
        titleLabel.attributedText = title.withTextStyle(.body2, color: .Text.secondary, alignment: .left)
        valueLabel.attributedText = value.withTextStyle(.body1Mono, color: .Text.primary, alignment: .left)

        if let badgeConfiguration {
            badgeView.configuration = badgeConfiguration
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
    }

    private func setup(trailingButtons: [TKButton]) {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 0

        valueLabel.numberOfLines = 0
        valueLabel.setContentHuggingPriority(.required, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        badgeView.setContentHuggingPriority(.required, for: .horizontal)

        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(badgeView)
        headerStackView.addArrangedSubview(UIView())

        actionsStackView.axis = .horizontal
        actionsStackView.spacing = 12
        actionsStackView.alignment = .center
        actionsStackView.setContentHuggingPriority(.required, for: .horizontal)
        actionsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        for button in trailingButtons {
            actionsStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.size.equalTo(28)
            }
        }

        valueRowStackView.axis = .horizontal
        valueRowStackView.alignment = .top
        valueRowStackView.spacing = 12
        valueRowStackView.addArrangedSubview(valueLabel)
        valueRowStackView.addArrangedSubview(actionsStackView)

        rootStackView.axis = .vertical
        rootStackView.addArrangedSubview(headerStackView)
        rootStackView.addArrangedSubview(valueRowStackView)

        addSubview(rootStackView)

        rootStackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
