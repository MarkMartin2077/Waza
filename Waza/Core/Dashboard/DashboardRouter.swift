import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showSessionDetailView(session: BJJSessionModel)
    func showGoalsPlanningView()
    func showPaywallView()
    func showDevSettingsView()
}

extension CoreRouter: DashboardRouter { }
