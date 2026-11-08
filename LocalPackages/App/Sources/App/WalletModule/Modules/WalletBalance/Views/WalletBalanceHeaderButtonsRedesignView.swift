import SnapKit
import TKCore
import TKUIKit
import UIKit

final class WalletBalanceHeaderButtonsRedesignView: UIView, ConfigurableView {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 0
        return view
    }()

    private let withdrawButton = TKIconCircleButton()
    private let depositButton = TKIconCircleButton()
    private let swapButton = TKIconCircleButton()
    private let stakeButton = TKIconCircleButton()

    private let tooltipsService: TooltipsService
    private var withdrawTooltipEnabled = false

    init(
        tooltipsService: TooltipsService,
        frame: CGRect = .zero
    ) {
        self.tooltipsService = tooltipsService
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        touchTooltipState()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        touchTooltipState()
    }

    struct Model {
        struct Button {
            let title: String
            let icon: UIImage
            let isEnabled: Bool
            let action: @MainActor () -> Void
        }

        let withdrawButton: Button
        let depositButton: Button
        let swapButton: Button?
        let stakeButton: Button?
        let withdrawTooltipEnabled: Bool
    }

    func configure(model: Model) {
        withdrawButton.configuration = buttonConfiguration(model: model.withdrawButton)
        depositButton.configuration = buttonConfiguration(model: model.depositButton)

        if let swap = model.swapButton {
            swapButton.configuration = buttonConfiguration(model: swap)
            swapButton.isHidden = false
        } else {
            swapButton.isHidden = true
        }

        if let stake = model.stakeButton {
            stakeButton.configuration = buttonConfiguration(model: stake)
            stakeButton.isHidden = false
        } else {
            stakeButton.isHidden = true
        }
        withdrawTooltipEnabled = model.withdrawTooltipEnabled
        touchTooltipState()
    }
}

private extension WalletBalanceHeaderButtonsRedesignView {
    func setup() {
        clipsToBounds = false

        stackView.addArrangedSubview(withdrawButton)
        stackView.addArrangedSubview(depositButton)
        stackView.addArrangedSubview(swapButton)
        stackView.addArrangedSubview(stakeButton)

        addSubview(stackView)
        setupConstraints()
    }

    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(NSDirectionalEdgeInsets.padding.bottom)
        }

        for button in [withdrawButton, depositButton, swapButton, stakeButton] {
            button.snp.makeConstraints { make in
                make.width.greaterThanOrEqualTo(76)
            }
        }
    }

    private func touchTooltipState() {
        guard withdrawTooltipEnabled else {
            return
        }
        tooltipsService.showTooltipIfNeeded(
            id: .walletBalanceWithdraw,
            sourceView: withdrawButton,
            targetActionViews: [withdrawButton],
            configuration: HintConfiguration(
                position: HintPosition(
                    tailParameters: TKTooltipView.tailParameters,
                    horizontal: .default,
                    vertical: .init(absolute: 0),
                    direction: .topRight
                ),
                maximumWidth: Layout.tooltipMaximumWidth,
                animationStyle: .bouncing
            )
        )
    }

    private func buttonConfiguration(model: Model.Button) -> TKIconCircleButton.Configuration {
        TKIconCircleButton.Configuration(
            title: model.title,
            icon: model.icon,
            isEnable: model.isEnabled,
            action: model.action
        )
    }
}

private extension NSDirectionalEdgeInsets {
    static var padding = NSDirectionalEdgeInsets(
        top: 0,
        leading: 16,
        bottom: 16,
        trailing: 16
    )
}

private extension WalletBalanceHeaderButtonsRedesignView {
    enum Layout {
        static let tooltipMaximumWidth: CGFloat = 280
    }
}
