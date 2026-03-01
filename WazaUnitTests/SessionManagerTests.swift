import Testing
import Foundation
@testable import Waza

// MARK: - Session CRUD

@Suite("SessionManager - CRUD") @MainActor
struct SessionManagerCRUDTests {

    func makeManager() -> SessionManager {
        SessionManager(services: MockBJJSessionServices(), logger: nil)
    }

    @Test("Creating a session adds it to the sessions array")
    func createSession() throws {
        // GIVEN
        let manager = makeManager()
        #expect(manager.sessions.isEmpty)

        // WHEN
        let session = try manager.createSession(duration: 3600, sessionType: .gi)

        // THEN
        #expect(manager.sessions.count == 1)
        #expect(manager.sessions.first?.sessionId == session.sessionId)
        #expect(manager.sessions.first?.sessionType == .gi)
        #expect(manager.sessions.first?.duration == 3600)
    }

    @Test("Updating a session persists the changes")
    func updateSession() throws {
        // GIVEN
        let manager = makeManager()
        var session = try manager.createSession(sessionType: .gi)

        // WHEN
        session.sessionType = .noGi
        session.notes = "Updated notes"
        try manager.updateSession(session)

        // THEN
        let updated = manager.getSession(id: session.sessionId)
        #expect(updated?.sessionType == .noGi)
        #expect(updated?.notes == "Updated notes")
    }

    @Test("Deleting a session removes it from the sessions array")
    func deleteSession() throws {
        // GIVEN
        let manager = makeManager()
        let session = try manager.createSession()
        #expect(manager.sessions.count == 1)

        // WHEN
        try manager.deleteSession(session)

        // THEN
        #expect(manager.sessions.isEmpty)
    }

    @Test("Creating multiple sessions accumulates correctly")
    func createMultipleSessions() throws {
        // GIVEN
        let manager = makeManager()

        // WHEN
        try manager.createSession(sessionType: .gi)
        try manager.createSession(sessionType: .noGi)
        try manager.createSession(sessionType: .openMat)

        // THEN
        #expect(manager.sessions.count == 3)
    }

    @Test("Deleting one of many sessions leaves the rest intact")
    func deleteOneOfManySessions() throws {
        // GIVEN
        let manager = makeManager()
        let toDelete = try manager.createSession(notes: "Delete me")
        try manager.createSession(notes: "Keep me")

        // WHEN
        try manager.deleteSession(toDelete)

        // THEN
        #expect(manager.sessions.count == 1)
        #expect(manager.sessions.first?.notes == "Keep me")
    }
}

// MARK: - Session Queries

@Suite("SessionManager - Queries") @MainActor
struct SessionManagerQueryTests {

    func makeManager() -> SessionManager {
        SessionManager(services: MockBJJSessionServices(), logger: nil)
    }

    @Test("getSession returns the correct session by ID")
    func getSessionById() throws {
        // GIVEN
        let manager = makeManager()
        let session = try manager.createSession(sessionType: .competition)

        // WHEN
        let found = manager.getSession(id: session.sessionId)

        // THEN
        #expect(found?.sessionId == session.sessionId)
        #expect(found?.sessionType == .competition)
    }

    @Test("getSession returns nil for an unknown ID")
    func getSessionUnknownId() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let found = manager.getSession(id: "unknown-id")

        // THEN
        #expect(found == nil)
    }

    @Test("getRecentSessions respects the requested limit")
    func getRecentSessionsLimit() throws {
        // GIVEN
        let manager = makeManager()
        for _ in 0..<7 {
            try manager.createSession()
        }

        // WHEN
        let recent = manager.getRecentSessions(limit: 5)

        // THEN
        #expect(recent.count == 5)
    }

    @Test("getRecentSessions returns all sessions when count is below the limit")
    func getRecentSessionsBelowLimit() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createSession()
        try manager.createSession()

        // WHEN
        let recent = manager.getRecentSessions(limit: 10)

        // THEN
        #expect(recent.count == 2)
    }

    @Test("getSessions filters sessions to the specified date range")
    func getSessionsInRange() throws {
        // GIVEN
        let manager = makeManager()
        let now = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        try manager.createSession(date: twoDaysAgo)    // inside range
        try manager.createSession(date: tenDaysAgo)    // outside range

        // WHEN
        let range = DateRange.lastDays(5)
        let result = manager.getSessions(in: range)

        // THEN
        #expect(result.count == 1)
    }

    @Test("getSessions returns empty when no sessions fall in the range")
    func getSessionsEmptyRange() throws {
        // GIVEN
        let manager = makeManager()
        let longAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        try manager.createSession(date: longAgo)

        // WHEN
        let range = DateRange.lastDays(7)
        let result = manager.getSessions(in: range)

        // THEN
        #expect(result.isEmpty)
    }
}

// MARK: - Session Stats

@Suite("SessionManager - Stats") @MainActor
struct SessionManagerStatsTests {

    func makeManager() -> SessionManager {
        SessionManager(services: MockBJJSessionServices(), logger: nil)
    }

    @Test("getSessionStats returns zero values when no sessions exist")
    func emptyStats() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let stats = manager.getSessionStats()

        // THEN
        #expect(stats.totalSessions == 0)
        #expect(stats.totalTrainingTime == 0)
        #expect(stats.averageSessionDuration == 0)
        #expect(stats.thisWeekSessions == 0)
        #expect(stats.thisMonthSessions == 0)
    }

    @Test("getSessionStats counts total sessions correctly")
    func totalSessionCount() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createSession()
        try manager.createSession()
        try manager.createSession()

        // WHEN
        let stats = manager.getSessionStats()

        // THEN
        #expect(stats.totalSessions == 3)
    }

    @Test("getSessionStats sums total training time across all sessions")
    func totalTrainingTime() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createSession(duration: 3600)
        try manager.createSession(duration: 5400)
        try manager.createSession(duration: 7200)

        // WHEN
        let stats = manager.getSessionStats()

        // THEN
        #expect(stats.totalTrainingTime == 16200)
    }

    @Test("getSessionStats calculates average session duration")
    func averageDuration() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createSession(duration: 3600)  // 1 hour
        try manager.createSession(duration: 7200)  // 2 hours

        // WHEN
        let stats = manager.getSessionStats()

        // THEN
        #expect(stats.averageSessionDuration == 5400)  // 1.5 hours average
    }

    @Test("getSessionStats counts sessions from the past 7 days")
    func thisWeekSessions() throws {
        // GIVEN
        let manager = makeManager()
        let now = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        try manager.createSession(date: now)
        try manager.createSession(date: threeDaysAgo)
        try manager.createSession(date: tenDaysAgo)   // should not count

        // WHEN
        let stats = manager.getSessionStats()

        // THEN
        #expect(stats.thisWeekSessions == 2)
    }

    @Test("getSessionStats counts sessions from the past 30 days")
    func thisMonthSessions() throws {
        // GIVEN
        let manager = makeManager()
        let now = Date()
        let twentyDaysAgo = Calendar.current.date(byAdding: .day, value: -20, to: now)!
        let fortyDaysAgo = Calendar.current.date(byAdding: .day, value: -40, to: now)!
        try manager.createSession(date: now)
        try manager.createSession(date: twentyDaysAgo)
        try manager.createSession(date: fortyDaysAgo)   // should not count

        // WHEN
        let stats = manager.getSessionStats()

        // THEN
        #expect(stats.thisMonthSessions == 2)
    }
}

// MARK: - Session Lifecycle

@Suite("SessionManager - Lifecycle") @MainActor
struct SessionManagerLifecycleTests {

    func makeManager() -> SessionManager {
        SessionManager(services: MockBJJSessionServices(), logger: nil)
    }

    @Test("clearAll removes all sessions")
    func clearAll() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createSession()
        try manager.createSession()
        #expect(manager.sessions.count == 2)

        // WHEN
        manager.clearAll()

        // THEN
        #expect(manager.sessions.isEmpty)
    }

    @Test("seedMockDataIfEmpty populates sessions when the manager is empty")
    func seedMockDataIfEmpty() {
        // GIVEN
        let manager = makeManager()
        #expect(manager.sessions.isEmpty)

        // WHEN
        manager.seedMockDataIfEmpty()

        // THEN
        #expect(!manager.sessions.isEmpty)
    }

    @Test("seedMockDataIfEmpty does not overwrite existing sessions")
    func seedMockDataDoesNotOverwrite() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createSession(notes: "Keep this session")
        let countBefore = manager.sessions.count

        // WHEN
        manager.seedMockDataIfEmpty()

        // THEN
        #expect(manager.sessions.count == countBefore)
        #expect(manager.sessions.first?.notes == "Keep this session")
    }
}

// MARK: - TrainingStatsManager

@Suite("TrainingStatsManager") @MainActor
struct TrainingStatsManagerTests {

    func makeManager() -> (stats: TrainingStatsManager, sessions: SessionManager) {
        let sessions = SessionManager(services: MockBJJSessionServices(), logger: nil)
        let stats = TrainingStatsManager(sessionManager: sessions)
        return (stats, sessions)
    }

    @Test("getTrainingSnapshot returns empty snapshot when no sessions exist")
    func emptySnapshot() {
        // GIVEN
        let (stats, _) = makeManager()

        // WHEN
        let snapshot = stats.getTrainingSnapshot(period: .lastMonth)

        // THEN
        #expect(snapshot.sessionCount == 0)
        #expect(snapshot.totalHours == 0)
        #expect(snapshot.typeBreakdown.isEmpty)
    }

    @Test("getTrainingSnapshot counts sessions in the given period")
    func snapshotSessionCount() throws {
        // GIVEN
        let (stats, sessions) = makeManager()
        let now = Date()
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: now)!
        try sessions.createSession(date: tenDaysAgo, duration: 3600)  // inside last month
        try sessions.createSession(date: sixtyDaysAgo, duration: 3600) // outside last month

        // WHEN
        let snapshot = stats.getTrainingSnapshot(period: .lastMonth)

        // THEN
        #expect(snapshot.sessionCount == 1)
    }

    @Test("getTrainingSnapshot calculates total hours correctly")
    func snapshotTotalHours() throws {
        // GIVEN
        let (stats, sessions) = makeManager()
        let now = Date()
        try sessions.createSession(date: now, duration: 3600)  // 1 hour
        try sessions.createSession(date: now, duration: 7200)  // 2 hours

        // WHEN
        let snapshot = stats.getTrainingSnapshot(period: .lastWeek)

        // THEN
        #expect(snapshot.totalHours == 3.0)
    }

    @Test("getTypeBreakdown returns proportions by session type")
    func typeBreakdown() throws {
        // GIVEN
        let (stats, sessions) = makeManager()
        try sessions.createSession(sessionType: .gi)
        try sessions.createSession(sessionType: .gi)
        try sessions.createSession(sessionType: .noGi)

        // WHEN
        let breakdown = stats.getTypeBreakdown()

        // THEN
        let giStat = breakdown.first { $0.sessionType == .gi }
        let noGiStat = breakdown.first { $0.sessionType == .noGi }
        #expect(giStat?.count == 2)
        #expect(noGiStat?.count == 1)
        #expect(giStat?.percentage ?? 0 > 0.5)
    }

    @Test("getTypeBreakdown returns empty for no sessions")
    func typeBreakdownEmpty() {
        // GIVEN
        let (stats, _) = makeManager()

        // WHEN
        let breakdown = stats.getTypeBreakdown()

        // THEN
        #expect(breakdown.isEmpty)
    }
}
