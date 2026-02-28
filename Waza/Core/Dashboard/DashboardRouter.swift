import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showSessionDetailView(session: BJJSessionModel)
    func showGoalsPlanningView()
    func showPaywallView()
    func showDevSettingsView()
    func showAIInsightsView()
    func showClassScheduleView()
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, onDismiss: (() -> Void)?)
}

extension CoreRouter: DashboardRouter { }
