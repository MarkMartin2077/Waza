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

    private(set) var imageName: String = Constants.randomImage

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

    func onGetStartedPressed() {
        interactor.trackEvent(event: Event.getStartedPressed)
        router.switchToCoreModule()
    }

    private func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        router.switchToCoreModule()
    }

    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)

        let delegate = CreateAccountDelegate(
            title: "Sign in",
            subtitle: "Connect to an existing account.",
            onDidSignIn: { isNewUser in
                self.handleDidSignIn(isNewUser: isNewUser)
            }
        )
        router.showCreateAccountView(delegate: delegate, onDismiss: nil)
    }

}

extension WelcomePresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: WelcomeDelegate)
        case onDisappear(delegate: WelcomeDelegate)
        case didSignIn(isNewUser: Bool)
        case signInPressed
        case getStartedPressed

        var eventName: String {
            switch self {
            case .onAppear:             return "WelcomeView_Appear"
            case .onDisappear:          return "WelcomeView_Disappear"
            case .didSignIn:            return "WelcomeView_DidSignIn"
            case .signInPressed:        return "WelcomeView_SignIn_Pressed"
            case .getStartedPressed:    return "WelcomeView_GetStarted_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .didSignIn(isNewUser: let isNewUser):
                return ["is_new_user": isNewUser]
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
