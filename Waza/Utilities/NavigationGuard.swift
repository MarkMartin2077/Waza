import Foundation

/// Prevents rapid double-taps on navigation triggers from pushing duplicate screens.
///
/// `SwiftfulRouting`'s `showScreen(_:)` and `.anyButton(_:)` have no built-in tap
/// debouncing — if the user taps a toolbar button twice in quick succession during
/// the push/present transition animation (~300-400 ms on iOS 26), both taps fire
/// and two screens get pushed.
///
/// Wrap the navigation call in `navGuard.perform { ... }` and subsequent taps
/// within the reset window are ignored.
///
/// ```swift
/// @Observable @MainActor
/// class MyPresenter {
///     private let navGuard = NavigationGuard()
///
///     func onTapGoals() {
///         navGuard.perform {
///             interactor.trackEvent(event: Event.goalsTapped)
///             router.showGoalsView()
///         }
///     }
/// }
/// ```
@MainActor
final class NavigationGuard {
    private var isNavigating = false
    private let resetInterval: Duration

    /// - Parameter resetInterval: How long to block subsequent calls after a `perform`.
    ///   Default 600 ms covers the typical SwiftUI push / sheet transition with a
    ///   small buffer. Bump it higher for heavier destinations if needed.
    init(resetInterval: Duration = .milliseconds(600)) {
        self.resetInterval = resetInterval
    }

    /// Executes `action` if no navigation is currently in flight. Silently ignores
    /// the call otherwise. Automatically re-enables after `resetInterval`.
    func perform(_ action: () -> Void) {
        guard !isNavigating else { return }
        isNavigating = true
        action()
        Task { @MainActor [resetInterval] in
            try? await Task.sleep(for: resetInterval)
            isNavigating = false
        }
    }
}
