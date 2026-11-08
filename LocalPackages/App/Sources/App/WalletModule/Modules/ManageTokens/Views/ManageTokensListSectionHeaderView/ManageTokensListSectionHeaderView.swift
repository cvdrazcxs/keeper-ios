import TKUIKit
import UIKit

final class ManageTokensListSectionHeaderView: UICollectionReusableView {
    static var elementKind = "ManageTokensListSectionHeaderView"

    struct Configuration: Hashable {
        let title: NSAttributedString

        init(title: String) {
            self.title = title.withTextStyle(.label1, color: .Text.primary)
        }
    }

    var configuration = Configuration(title: "Title") {
        didSet {
            didUpdateConfiguration()
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    let titleLabel = UILabel()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        titleLabel.numberOfLines = 0

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(self).inset(2)
            make.top.bottom.equalTo(self).inset(12)
        }
    }

    private func didUpdateConfiguration() {
        titleLabel.attributedText = configuration.title
    }
}
