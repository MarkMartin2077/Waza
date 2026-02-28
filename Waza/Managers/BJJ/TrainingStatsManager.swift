import Foundation

@Observable
@MainActor
class TrainingStatsManager {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot {
        let periodSessions = sessionManager.getSessions(in: period)
        let totalTime = periodSessions.reduce(0.0) { $0 + $1.duration }
        let avgDuration = periodSessions.isEmpty ? 0.0 : totalTime / Double(periodSessions.count)

        return TrainingSnapshot(
            period: period,
            sessionCount: periodSessions.count,
            totalHours: totalTime / 3600,
            avgDurationMinutes: Int(avgDuration / 60),
            typeBreakdown: getTypeBreakdown(sessions: periodSessions),
            sessionFrequency: getSessionFrequency(sessions: periodSessions, period: period)
        )
    }

    func getTypeBreakdown() -> [TypeStat] {
        getTypeBreakdown(sessions: sessionManager.sessions)
    }

    func getTypeBreakdown(for period: DateRange) -> [TypeStat] {
        getTypeBreakdown(sessions: sessionManager.getSessions(in: period))
    }

    private func getTypeBreakdown(sessions: [BJJSessionModel]) -> [TypeStat] {
        guard !sessions.isEmpty else { return [] }
        let total = Double(sessions.count)
        return SessionType.allCases.compactMap { type in
            let count = sessions.filter { $0.sessionType == type }.count
            guard count > 0 else { return nil }
            return TypeStat(sessionType: type, count: count, percentage: Double(count) / total)
        }.sorted { $0.count > $1.count }
    }

    private func getSessionFrequency(sessions: [BJJSessionModel], period: DateRange) -> [DayCount] {
        let calendar = Calendar.current
        var current = calendar.startOfDay(for: period.start)
        let end = calendar.startOfDay(for: period.end)
        var result: [DayCount] = []

        while current <= end {
            let next = calendar.date(byAdding: .day, value: 1, to: current) ?? current
            let count = sessions.filter { $0.date >= current && $0.date < next }.count
            result.append(DayCount(date: current, count: count))
            current = next
        }

        return result
    }
}
