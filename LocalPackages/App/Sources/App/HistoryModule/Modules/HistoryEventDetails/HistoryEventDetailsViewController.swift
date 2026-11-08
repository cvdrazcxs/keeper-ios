import TKUIKit
import UIKit

final class HistoryEventDetailsViewController: GenericViewViewController<HistoryEventDetailsView>, TKBottomSheetScrollContentViewController {
    var scrollView: UIScrollView {
        popUpViewController.scrollView
    }

    var didUpdateHeight: (() -> Void)?

    var headerConfiguration: TKBottomSheetHeaderConfiguration?

    var didUpdateHeaderConfiguration: ((TKBottomSheetHeaderConfiguration?) -> Void)?

    func calculateHeight(withWidth width: CGFloat) -> CGFloat {
        popUpViewController.calculateHeight(withWidth: width)
    }

    private let viewModel: HistoryEventDetailsViewModel

    private let popUpViewController = TKPopUp.ViewController()

    init(viewModel: HistoryEventDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupBindings()
        viewModel.viewDidLoad()
    }
}

private extension HistoryEventDetailsViewController {
    func setupBindings() {
        viewModel.didUpdateConfiguration = { [weak self] configuration in
            self?.popUpViewController.configuration = configuration
            self?.didUpdateHeight?()
        }

        viewModel.didUpdateHeaderConfiguration = { [weak self] headerConfiguration in
            self?.headerConfiguration = headerConfiguration
            self?.didUpdateHeaderConfiguration?(headerConfiguration)
        }
    }

    func setup() {
        setupModalContent()
    }

    func setupModalContent() {
        addChild(popUpViewController)
        customView.embedContent(popUpViewController.view)
        popUpViewController.didMove(toParent: self)
    }
}
