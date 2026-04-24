import Foundation

struct CalendarDayModel: Identifiable, Equatable {
    let id: String                              // "yyyy-MM-dd"
    let date: Date                              // startOfDay
    let sessions: [BJJSessionModel]
    let scheduledOccurrences: [ScheduledClassOccurrence]
    let isToday: Bool
    let isInDisplayedMonth: Bool
    let isFuture: Bool

    var hasSessions: Bool { !sessions.isEmpty }
    var hasScheduled: Bool { !scheduledOccurrences.isEmpty }

    var primaryKanji: String? {
        sessions.last?.sessionType.kanji ?? scheduledOccurrences.first?.schedule.sessionType.kanji
    }

    static func == (lhs: CalendarDayModel, rhs: CalendarDayModel) -> Bool {
        lhs.id == rhs.id
            && lhs.sessions.map(\.id) == rhs.sessions.map(\.id)
            && lhs.scheduledOccurrences.map(\.id) == rhs.scheduledOccurrences.map(\.id)
            && lhs.isToday == rhs.isToday
            && lhs.isInDisplayedMonth == rhs.isInDisplayedMonth
            && lhs.isFuture == rhs.isFuture
    }
}

struct ScheduledClassOccurrence: Identifiable, Equatable {
    let id: String              // "\(scheduleId)-\(yyyyMMddHHmm)"
    let schedule: ClassScheduleModel
    let gym: GymLocationModel
    let occursAt: Date

    static func == (lhs: ScheduledClassOccurrence, rhs: ScheduledClassOccurrence) -> Bool {
        lhs.id == rhs.id
    }
}
