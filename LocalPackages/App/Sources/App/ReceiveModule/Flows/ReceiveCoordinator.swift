import TKCoordinator

@MainActor
protocol ReceiveCoordinator: Coordinator {
    var didClose: (() -> Void)? { get set }
}
