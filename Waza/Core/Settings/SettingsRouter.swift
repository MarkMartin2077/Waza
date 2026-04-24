//
//  SettingsRouter.swift
//  
//
//  
//
import SwiftUI

@MainActor
protocol SettingsRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func switchToOnboardingModule()
    func openURL(_ url: URL)
}

extension CoreRouter: SettingsRouter {
    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
