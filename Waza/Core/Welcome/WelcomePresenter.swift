//
//  WelcomePresenter.swift
//  Waza
//
import SwiftUI

@Observable
@MainActor
class WelcomePresenter {

    private let interactor: WelcomeInteractor
    private let router: WelcomeRouter

    var isGuestContinuing = false

    init(interactor: WelcomeInteractor, router: WelcomeRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: WelcomeDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: WelcomeDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onContinueAsGuestPressed() {
        guard !isGuestContinuing else { return }
        interactor.trackEvent(event: Event.continueAsGuestPressed)
        isGuestContinuing = true

        Task {
            defer { isGuestContinuing = false }
            do {
                // Use existing anonymous auth if AppPresenter.checkUserStatus() already created it;
                // otherwise create one now. Either way the user needs full logIn() to populate managers.
                let user: UserAuthInfo
                let isNewUser: Bool
                if let existing = interactor.auth {
                    user = existing
                    isNewUser = false
                } else {
                    let result = try await interactor.signInAnonymously()
                    user = result.user
                    isNewUser = result.isNewUser
                }
                try await interactor.logIn(user: user, isNewUser: isNewUser)
                interactor.trackEvent(event: Event.continueAsGuestSuccess)
                handleDidSignIn(isNewUser: isNewUser)
            } catch {
                interactor.trackEvent(event: Event.continueAsGuestFail(error: error))
                router.showAlert(error: error)
            }
        }
    }

    func onGetStartedPressed() {
        interactor.trackEvent(event: Event.getStartedPressed)

        let delegate = CreateAccountDelegate(
            title: "Continue to Waza",
            subtitle: "Sign in to save sessions and sync across devices.",
            kanji: "入",
            onDidSignIn: { [weak self] isNewUser in
                self?.handleDidSignIn(isNewUser: isNewUser)
            }
        )
        router.showCreateAccountView(delegate: delegate, onDismiss: nil)
    }

    private func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))

        if interactor.hasCompletedOnboarding {
            let delegate = WelcomeBackDelegate(
                isNewUser: false,
                onComplete: { [weak self] in
                    self?.router.switchToCoreModule()
                }
            )
            router.showWelcomeBackView(delegate: delegate)
        } else {
            router.showOnboardingView()
        }
    }

}

extension WelcomePresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: WelcomeDelegate)
        case onDisappear(delegate: WelcomeDelegate)
        case didSignIn(isNewUser: Bool)
        case getStartedPressed
        case continueAsGuestPressed
        case continueAsGuestSuccess
        case continueAsGuestFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                 return "WelcomeView_Appear"
            case .onDisappear:              return "WelcomeView_Disappear"
            case .didSignIn:                return "WelcomeView_DidSignIn"
            case .getStartedPressed:        return "WelcomeView_GetStarted_Pressed"
            case .continueAsGuestPressed:   return "WelcomeView_Guest_Start"
            case .continueAsGuestSuccess:   return "WelcomeView_Guest_Success"
            case .continueAsGuestFail:      return "WelcomeView_Guest_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .didSignIn(isNewUser: let isNewUser):
                return ["is_new_user": isNewUser]
            case .continueAsGuestFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .continueAsGuestFail: return .severe
            default:                   return .analytic
            }
        }
    }
}
