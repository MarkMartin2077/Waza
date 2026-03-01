import SwiftUI

@MainActor
protocol SessionsRouter: GlobalRouter {
    func showSessionDetailView(session: BJJSessionModel)
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, onDismiss: (() -> Void)?)
}

extension CoreRouter: SessionsRouter { }
