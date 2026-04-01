import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showSessionDetailView(session: BJJSessionModel)
    func showPaywallView()
    func showDevSettingsView()
    func showAIInsightsView()
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?)
}

extension CoreRouter: DashboardRouter { }
