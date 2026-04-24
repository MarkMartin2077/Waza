//
//  CreateAccountPresenter.swift
//
//
//
//
import SwiftUI

@Observable
@MainActor
class CreateAccountPresenter {

    enum AuthProvider {
        case apple
        case google
    }

    private let interactor: CreateAccountInteractor
    private let router: CreateAccountRouter

    var activeProvider: AuthProvider?

    init(interactor: CreateAccountInteractor, router: CreateAccountRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: CreateAccountDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: CreateAccountDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onDismissPressed() {
        interactor.trackEvent(event: Event.dismissPressed)
        router.dismissScreen()
    }

    func onSignInApplePressed(delegate: CreateAccountDelegate) {
        guard activeProvider == nil else { return }
        interactor.trackEvent(event: Event.appleAuthStart)
        activeProvider = .apple

        Task {
            do {
                let result = try await interactor.signInApple()
                interactor.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))

                try await interactor.logIn(user: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))

                activeProvider = nil
                router.dismissScreen()
                delegate.onDidSignIn?(result.isNewUser)
            } catch {
                activeProvider = nil
                interactor.trackEvent(event: Event.appleAuthFail(error: error))
                router.showAlert(error: error)
            }
        }
    }

    func onSignInGooglePressed(delegate: CreateAccountDelegate) {
        guard activeProvider == nil else { return }
        interactor.trackEvent(event: Event.googleAuthStart)
        activeProvider = .google

        Task {
            do {
                let result = try await interactor.signInGoogle()
                interactor.trackEvent(event: Event.googleAuthSuccess(user: result.user, isNewUser: result.isNewUser))

                try await interactor.logIn(user: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.googleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))

                activeProvider = nil
                router.dismissScreen()
                delegate.onDidSignIn?(result.isNewUser)
            } catch {
                activeProvider = nil
                interactor.trackEvent(event: Event.googleAuthFail(error: error))
                router.showAlert(error: error)
            }
        }
    }

}

extension CreateAccountPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: CreateAccountDelegate)
        case onDisappear(delegate: CreateAccountDelegate)
        case dismissPressed
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)
        case googleAuthStart
        case googleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case googleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case googleAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                return "CreateAccountView_Appear"
            case .onDisappear:             return "CreateAccountView_Disappear"
            case .dismissPressed:          return "CreateAccountView_Dismiss_Pressed"
            case .appleAuthStart:          return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess:        return "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess:   return "CreateAccountView_AppleAuth_LoginSuccess"
            case .appleAuthFail:           return "CreateAccountView_AppleAuth_Fail"
            case .googleAuthStart:          return "CreateAccountView_GoogleAuth_Start"
            case .googleAuthSuccess:        return "CreateAccountView_GoogleAuth_Success"
            case .googleAuthLoginSuccess:   return "CreateAccountView_GoogleAuth_LoginSuccess"
            case .googleAuthFail:           return "CreateAccountView_GoogleAuth_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser),
                .googleAuthSuccess(user: let user, isNewUser: let isNewUser),
                .googleAuthLoginSuccess(user: let user, isNewUser: let isNewUser)
                :
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error), .googleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .appleAuthFail, .googleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
