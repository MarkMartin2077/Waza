import SwiftUI

@MainActor
protocol ClassScheduleRouter: GlobalRouter {
    func showGymSetupView(existingGym: GymLocationModel?, onDismiss: (() -> Void)?)
    func showAddScheduleSheet(gymId: String, existingSchedule: ClassScheduleModel?, onDismiss: (() -> Void)?)
}

extension CoreRouter: ClassScheduleRouter { }
