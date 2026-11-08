import KeeperCore
import SwiftUI
import TKCore
import TKUIKit
import UIKit

final class FakeBalanceEditorHostingViewController: TKHostingController<FakeBalanceEditorScreen> {
    init(viewModel: FakeBalanceEditorViewModel) {
        super.init(content: FakeBalanceEditorScreen(viewModel: viewModel))
    }

    @available(*, unavailable)
    @MainActor
    dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Background.page
    }
}

struct FakeBalanceEditorAssembly {
    @MainActor
    static func module(
        wallet: Wallet,
        managedBalanceStore: ManagedBalanceStore,
        appSettings: TKCore.AppSettings
    ) -> FakeBalanceEditorHostingViewController {
        let viewModel = FakeBalanceEditorViewModel(
            wallet: wallet,
            managedBalanceStore: managedBalanceStore,
            appSettings: appSettings
        )
        return FakeBalanceEditorHostingViewController(viewModel: viewModel)
    }
}
