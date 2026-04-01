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
    func showPaywallView()
}

extension CoreRouter: SettingsRouter {
    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
