import KeeperCore
import TKCoordinator

enum PickMultichainAddressCoordinatorEvent {
    case select(MultichainWalletAddress)
    case copy(MultichainWalletAddress)
    case close
}

@MainActor
protocol PickMultichainAddressCoordinator: Coordinator {
    func startHandlingEvents() -> AsyncStream<PickMultichainAddressCoordinatorEvent>
}
