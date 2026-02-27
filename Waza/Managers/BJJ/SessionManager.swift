import SwiftData
import Foundation

@Observable
@MainActor
class SessionManager {
    private let modelContext: ModelContext

    private(set) var sessions: [BJJSessionModel] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<BJJSessionModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        sessions = (try? modelContext.fetch(descriptor)) ?? []
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
        let session = BJJSessionModel(
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
        modelContext.insert(session)
        try modelContext.save()
        refresh()
        return session
    }

    func updateSession(_ session: BJJSessionModel) throws {
        try modelContext.save()
        refresh()
    }

    func deleteSession(_ session: BJJSessionModel) throws {
        modelContext.delete(session)
        try modelContext.save()
        refresh()
    }

    func getSession(id: String) -> BJJSessionModel? {
        sessions.first { $0.id == id }
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

    // Seed mock data for preview contexts
    func seedMockDataIfEmpty() {
        guard sessions.isEmpty else { return }
        for session in BJJSessionModel.mocks {
            modelContext.insert(session)
        }
        try? modelContext.save()
        refresh()
    }
}
