import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showSessionDetailView(session: BJJSessionModel)
    func showDevSettingsView()
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?)
    func showTechniqueJournalView()
    func showMonthlyReportView()
}

extension CoreRouter: DashboardRouter { }
