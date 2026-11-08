import Foundation

public struct TKUIDevPreferences: Equatable {
    public var showsTouches: Bool

    public init(showsTouches: Bool = false) {
        self.showsTouches = showsTouches
    }
}

@MainActor
public final class TKDevPreferencesManager {
    public typealias DidUpdatePreferencesClosure = (TKUIDevPreferences) -> Void

    public static let shared = TKDevPreferencesManager()

    public var preferences: TKUIDevPreferences {
        didSet {
            guard preferences != oldValue else { return }
            didUpdatePreferences()
        }
    }

    public var showsTouches: Bool {
        get {
            preferences.showsTouches
        }
        set {
            preferences.showsTouches = newValue
        }
    }

    private var observations = [UUID: DidUpdatePreferencesClosure]()

    init(preferences: TKUIDevPreferences = .init()) {
        self.preferences = preferences
    }

    public func addEventObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping @MainActor (T, TKUIDevPreferences) -> Void
    ) {
        let id = UUID()
        let eventHandler: DidUpdatePreferencesClosure = { [weak self, weak observer] preferences in
            guard let observer else {
                self?.observations.removeValue(forKey: id)
                return
            }

            closure(observer, preferences)
        }
        observations[id] = eventHandler
    }

    private func didUpdatePreferences() {
        observations.forEach { $0.value(preferences) }
    }
}
