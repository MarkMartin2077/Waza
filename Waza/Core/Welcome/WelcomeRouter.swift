//
//  WelcomeRouter.swift
//  Waza
//

@MainActor
protocol WelcomeRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func switchToCoreModule()
}

extension CoreRouter: WelcomeRouter { }
