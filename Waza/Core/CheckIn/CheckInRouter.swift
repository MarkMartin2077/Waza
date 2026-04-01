import SwiftUI

@MainActor
protocol CheckInRouter: GlobalRouter {
    func showSessionEntryView(attendanceRecord: ClassAttendanceModel?, onDismiss: (() -> Void)?)
}

extension CoreRouter: CheckInRouter { }
