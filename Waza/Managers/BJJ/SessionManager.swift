import Foundation

@Observable
@MainActor
class SessionManager {
    private let localService: BJJSessionLocalService
    private let remoteService: RemoteBJJSessionService

    private(set) var sessions: [BJJSessionModel] = []

    init(localService: BJJSessionLocalService, remoteService: RemoteBJJSessionService) {
        self.localService = localService
        self.remoteService = remoteService
        refresh()
    }

    func refresh() {
        sessions = localService.getSessions()
    }

    @discardableResult
    func createSession(
        date: Date = Date(),
        duration: TimeInterval = 5400,
        sessionType: SessionType = .gi,
        academy: String? = nil,
        instructor: String? = nil,
        focusAreas: [String] = [],
        notes: String? = nil,
        preSessionMood: Int? = nil,
        postSessionMood: Int? = nil,
        roundsCount: Int = 0,
        whatWorkedWell: String? = nil,
        needsImprovement: String? = nil,
        keyInsights: String? = nil
    ) throws -> BJJSessionModel {
        let model = BJJSessionModel(
            date: date,
            duration: duration,
            sessionType: sessionType,
            academy: academy,
            instructor: instructor,
            focusAreas: focusAreas,
            notes: notes,
            preSessionMood: preSessionMood,
            postSessionMood: postSessionMood,
            roundsCount: roundsCount,
            whatWorkedWell: whatWorkedWell,
            needsImprovement: needsImprovement,
            keyInsights: keyInsights
        )
        try localService.create(model)
        refresh()
        return model
    }

    func updateSession(_ model: BJJSessionModel) throws {
        try localService.update(model)
        refresh()
    }

    func deleteSession(_ model: BJJSessionModel) throws {
        try localService.delete(id: model.sessionId)
        refresh()
    }

    func getSession(id: String) -> BJJSessionModel? {
        sessions.first { $0.sessionId == id }
    }

    func getRecentSessions(limit: Int = 5) -> [BJJSessionModel] {
        Array(sessions.prefix(limit))
    }

    func getSessions(in dateRange: DateRange) -> [BJJSessionModel] {
        sessions.filter { $0.date >= dateRange.start && $0.date <= dateRange.end }
    }

    func getSessionStats() -> SessionStats {
        let now = Date()
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let monthStart = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now

        let totalTime = sessions.reduce(0) { $0 + $1.duration }
        let avgDuration = sessions.isEmpty ? 0 : totalTime / Double(sessions.count)
        let weekSessions = sessions.filter { $0.date >= weekStart }.count
        let monthSessions = sessions.filter { $0.date >= monthStart }.count

        return SessionStats(
            totalSessions: sessions.count,
            totalTrainingTime: totalTime,
            averageSessionDuration: avgDuration,
            thisWeekSessions: weekSessions,
            thisMonthSessions: monthSessions
        )
    }

    func seedMockDataIfEmpty() {
        guard sessions.isEmpty else { return }
        for model in BJJSessionModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }
}
