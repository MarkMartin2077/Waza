import SwiftUI

@MainActor
protocol SessionsRouter: GlobalRouter {
    func showSessionDetailView(session: BJJSessionModel)
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?)
}

extension CoreRouter: SessionsRouter { }
