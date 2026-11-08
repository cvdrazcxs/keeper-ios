import KeeperCore
import TKUIKit
import UIKit

final class HistoryView: UIView {
    let safeAreaBar = UIView()
    let navigationBar: SomeOf<TKNavigationBar, TKUINavigationBar>
    let listContainerView = UIView()
    let tabsView = TKTabsView()

    convenience init(navigationBar: TKNavigationBar) {
        self.init(navigationBar: .certain(navigationBar))
    }

    convenience init(navigationBar: TKUINavigationBar) {
        self.init(navigationBar: .certain(navigationBar))
    }

    private init(navigationBar: SomeOf<TKNavigationBar, TKUINavigationBar>) {
        self.navigationBar = navigationBar
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension HistoryView {
    func setup() {
        safeAreaBar.backgroundColor = .Background.page
        backgroundColor = .Background.page
        addSubview(listContainerView)
        addSubview(tabsView)
        addSubview(navigationBar.uiView)
        addSubview(safeAreaBar)

        setupConstraints()
    }

    func setupConstraints() {
        safeAreaBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
        }
        navigationBar.uiView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
        }
        tabsView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.uiView.snp.bottom)
            make.left.right.equalTo(self)
        }
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.right.bottom.equalTo(self)
        }
    }
}
