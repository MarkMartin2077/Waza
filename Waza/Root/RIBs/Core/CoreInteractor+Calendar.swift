import Foundation

// Extension for CalendarInteractor conformance.
// Follows the same +BJJ convention used throughout this codebase.
extension CoreInteractor {

    var gymsById: [String: GymLocationModel] {
        Dictionary(uniqueKeysWithValues: classScheduleManager.gyms.map { ($0.gymId, $0) })
    }

    func buildCalendarMonth(anchor: Date) -> [CalendarDayModel] {
        CalendarMonthBuilder.buildMonth(
            anchor: anchor,
            sessions: sessionManager.sessions,
            schedules: classScheduleManager.schedules,
            gymsById: gymsById
        )
    }

    func sessionsOn(date: Date) -> [BJJSessionModel] {
        let calendar = Calendar.current
        return sessionManager.sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}
