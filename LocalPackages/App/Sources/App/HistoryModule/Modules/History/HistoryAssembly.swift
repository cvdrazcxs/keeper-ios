import Foundation
import KeeperCore
import TKCore

enum HistoryPresentationStyle {
    case modal(closeAction: (() -> Void)?)
    case push(closeAction: (() -> Void)?)

    var closeAction: (() -> Void)? {
        switch self {
        case let .modal(closeAction), let .push(closeAction):
            closeAction
        }
    }
}

struct HistoryAssembly {
    private init() {}
    @MainActor static func module(
        wallet: Wallet,
        historyListViewController: HistoryListViewController,
        historyListModuleInput: HistoryListModuleInput,
        keeperCoreMainAssembly: KeeperCore.MainAssembly,
        presentationStyle: HistoryPresentationStyle
    ) -> MVVMModule<HistoryViewController, HistoryModuleOutput, HistoryModuleInput> {
        let viewModel = HistoryV2ViewModelImplementation(
            wallet: wallet,
            backgroundUpdate: keeperCoreMainAssembly.backgroundUpdateAssembly.backgroundUpdate,
            historyListModuleInput: historyListModuleInput,
            configuration: keeperCoreMainAssembly.configurationAssembly.configuration,
            presentationStyle: presentationStyle
        )
        let viewController = HistoryViewController(
            viewModel: viewModel,
            historyListViewController: historyListViewController
        )
        return .init(view: viewController, output: viewModel, input: viewModel)
    }
}
