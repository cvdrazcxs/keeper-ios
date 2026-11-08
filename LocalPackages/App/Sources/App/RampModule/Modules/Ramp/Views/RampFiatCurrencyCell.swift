import SnapKit
import TKUIKit
import UIKit

final class RampFiatCurrencyCell: UICollectionViewCell {
    struct Model: Hashable {
        let headingTitle: String
        let rowCaption: String
        let currencyCode: String?
        let currencyImage: URL?
        let showsCurrencyShimmer: Bool
    }

    var didTapCurrencyButton: (() -> Void)?

    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    private let headingContainer = UIView()

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    private let rowCaptionLabel = UILabel()

    private let rowCenterWrapper = UIView()

    private let currencySlotStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()

    private let currencyButton = CurrencyPickerButton()

    private let currencyShimmer = TKShimmerView()

    private var displaysCurrencyShimmer = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        headingLabel.attributedText = nil
        rowCaptionLabel.attributedText = nil
        currencyButton.configuration = nil
        displaysCurrencyShimmer = false
        currencyShimmer.stopAnimation()
        currencyButton.isHidden = false
        currencyShimmer.isHidden = true
    }

    func configure(model: Model) {
        displaysCurrencyShimmer = model.showsCurrencyShimmer

        headingLabel.attributedText = model.headingTitle.withTextStyle(
            .h2,
            color: .Text.primary,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        rowCaptionLabel.attributedText = model.rowCaption.withTextStyle(
            .body1,
            color: .Text.secondary,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        if model.showsCurrencyShimmer {
            currencyButton.isHidden = true
            currencyShimmer.isHidden = false
        } else {
            currencyShimmer.isHidden = true
            currencyButton.isHidden = model.currencyCode == nil
            currencyButton.configuration = CurrencyPickerButton.Configuration(
                currencyCode: model.currencyCode,
                image: .urlImage(model.currencyImage),
                currencyCodeTextStyle: .body1
            )
        }
    }

    func resumeCurrencyShimmerIfNeeded() {
        guard displaysCurrencyShimmer else { return }
        currencyShimmer.startAnimation()
    }

    func pauseCurrencyShimmer() {
        currencyShimmer.stopAnimation()
    }

    private func setup() {
        contentView.addSubview(rootStack)
        rootStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        rowCaptionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        currencySlotStack.setContentHuggingPriority(.required, for: .horizontal)
        currencySlotStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        currencySlotStack.addArrangedSubview(currencyButton)
        currencySlotStack.addArrangedSubview(currencyShimmer)

        currencyShimmer.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(24)
        }

        rootStack.addArrangedSubview(headingContainer)
        headingContainer.addSubview(headingLabel)
        headingLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        rootStack.addArrangedSubview(rowCenterWrapper)

        rowCenterWrapper.addSubview(rowStack)
        rowStack.addArrangedSubview(rowCaptionLabel)
        rowStack.addArrangedSubview(currencySlotStack)

        rowStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        currencyButton.didTap = { [weak self] in
            self?.didTapCurrencyButton?()
        }
    }
}
