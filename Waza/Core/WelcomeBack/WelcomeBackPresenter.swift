//
//  WelcomeBackPresenter.swift
//  Waza
//
import SwiftUI

@Observable
@MainActor
class WelcomeBackPresenter {

    private let interactor: WelcomeBackInteractor
    private let router: WelcomeBackRouter

    var showContent: Bool = false
    var hasCompleted: Bool = false

    init(interactor: WelcomeBackInteractor, router: WelcomeBackRouter) {
        self.interactor = interactor
        self.router = router
    }

    var name: String {
        interactor.currentUserName
    }

    func onViewAppear(delegate: WelcomeBackDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))

        Task {
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                showContent = true
            }
            interactor.playHaptic(option: .success)

            try? await Task.sleep(for: .milliseconds(1500))
            completeIfNeeded(delegate: delegate, trigger: .auto)
        }
    }

    func onViewTapped(delegate: WelcomeBackDelegate) {
        guard !hasCompleted else { return }
        interactor.trackEvent(event: Event.tapSkip(delegate: delegate))
        completeIfNeeded(delegate: delegate, trigger: .manual)
    }

    func completeIfNeeded(delegate: WelcomeBackDelegate, trigger: CompleteTrigger) {
        guard !hasCompleted else { return }
        hasCompleted = true
        interactor.trackEvent(event: Event.complete(delegate: delegate, trigger: trigger))
        router.dismissScreen()
        delegate.onComplete?()
    }

    enum CompleteTrigger: String {
        case auto
        case manual
    }
}

extension WelcomeBackPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: WelcomeBackDelegate)
        case tapSkip(delegate: WelcomeBackDelegate)
        case complete(delegate: WelcomeBackDelegate, trigger: CompleteTrigger)

        var eventName: String {
            switch self {
            case .onAppear: return "WelcomeBackView_Appear"
            case .tapSkip:  return "WelcomeBackView_TapSkip"
            case .complete: return "WelcomeBackView_Complete"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate),
                 .tapSkip(delegate: let delegate):
                return delegate.eventParameters
            case .complete(delegate: let delegate, trigger: let trigger):
                var dict = delegate.eventParameters ?? [:]
                dict["trigger"] = trigger.rawValue
                return dict
            }
        }

        var type: LogType { .analytic }
    }
}
