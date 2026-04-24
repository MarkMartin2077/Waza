import SwiftUI

@MainActor
protocol CalendarInteractor: GlobalInteractor {
    var allSessions: [BJJSessionModel] { get }
    var schedules: [ClassScheduleModel] { get }
    var gymsById: [String: GymLocationModel] { get }
    func buildCalendarMonth(anchor: Date) -> [CalendarDayModel]
    func sessionsOn(date: Date) -> [BJJSessionModel]
}

extension CoreInteractor: CalendarInteractor { }
