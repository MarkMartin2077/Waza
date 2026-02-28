import Foundation

@Observable
@MainActor
class SessionManager {
    private let localService: BJJSessionLocalService
    private let remoteService: RemoteBJJSessionService
    private let logger: LogManager?
    private var userId: String?

    private(set) var sessions: [BJJSessionModel] = []

    init(services: BJJSessionServices, logger: LogManager? = nil) {
        self.localService = services.local
        self.remoteService = services.remote
        self.logger = logger
        refresh()
    }

    // MARK: - Lifecycle

    /// Synchronous — returns immediately after storing userId and queuing a background sync.
    /// The app shows locally-cached data at once; remote data merges in silently.
    func logIn(userId: String) {
        self.userId = userId
        guard BJJSyncHelper.shouldSync(key: BJJSyncHelper.sessionsSyncKey, userId: userId) else { return }
        Task { await syncFromRemote(userId: userId) }
    }

    func logOut() {
        userId = nil
    }

    // MARK: - Read

    func refresh() {
        sessions = localService.getSessions()
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

    // MARK: - Write

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
        syncToRemote(model)
        return model
    }

    func updateSession(_ model: BJJSessionModel) throws {
        try localService.update(model)
        refresh()
        syncToRemote(model)
    }

    func deleteSession(_ model: BJJSessionModel) throws {
        try localService.delete(id: model.sessionId)
        refresh()
        deleteFromRemote(id: model.sessionId)
    }

    // MARK: - Wipe

    func clearAll() {
        if let userId {
            BJJSyncHelper.clearSyncTimestamp(key: BJJSyncHelper.sessionsSyncKey, userId: userId)
        }
        logOut()
        try? localService.deleteAll()
        sessions = []
    }

    func seedMockDataIfEmpty() {
        guard sessions.isEmpty else { return }
        for model in BJJSessionModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }

    // MARK: - Private

    private func syncFromRemote(userId: String) async {
        do {
            let remoteModels = try await remoteService.getSessions(userId: userId, limit: 50)
            let localIds = Set(sessions.map { $0.sessionId })
            var changed = false
            for model in remoteModels where !localIds.contains(model.sessionId) {
                try? localService.create(model)
                changed = true
            }
            if changed { refresh() }
            BJJSyncHelper.markSynced(key: BJJSyncHelper.sessionsSyncKey, userId: userId)
        } catch {
            logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "SessionManager", context: "Sync", error: error))
        }
    }

    private func syncToRemote(_ model: BJJSessionModel) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.saveSession(model, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "SessionManager", context: "Save", error: error))
            }
        }
    }

    private func deleteFromRemote(id: String) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.deleteSession(id: id, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "SessionManager", context: "Delete", error: error))
            }
        }
    }
}
