//
//  WelcomeRouter.swift
//  Waza
//

@MainActor
protocol WelcomeRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func switchToCoreModule()
    func showOnboardingView()
    func showWelcomeBackView(delegate: WelcomeBackDelegate)
}

extension CoreRouter: WelcomeRouter { }
