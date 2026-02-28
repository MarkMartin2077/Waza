import Foundation

@Observable
@MainActor
class AchievementManager {
    private let localService: AchievementLocalService
    private let remoteService: RemoteAchievementService
    private let logger: LogManager?
    private var userId: String?

    private(set) var earnedAchievements: [AchievementEarnedModel] = []

    init(services: AchievementServices, logger: LogManager? = nil) {
        self.localService = services.local
        self.remoteService = services.remote
        self.logger = logger
        refresh()
    }

    // MARK: - Lifecycle

    /// Synchronous — returns immediately; merges remote-only records in the background.
    func logIn(userId: String) {
        self.userId = userId
        guard BJJSyncHelper.shouldSync(key: BJJSyncHelper.achievementsSyncKey) else { return }
        Task { await syncFromRemote(userId: userId) }
    }

    func logOut() {
        userId = nil
    }

    // MARK: - Read

    func refresh() {
        earnedAchievements = localService.getAchievements()
    }

    func isEarned(_ id: AchievementId) -> Bool {
        earnedAchievements.contains { $0.achievementId == id.rawValue }
    }

    // MARK: - Write

    @discardableResult
    func checkAndAward(event: AchievementEvent, sessionStats: SessionStats, streakCount: Int) -> [AchievementId] {
        switch event {
        case .sessionLogged(let totalCount, let streak):
            return checkSessionAchievements(totalCount: totalCount, streak: streak)
        case .goalCompleted:
            return award(.firstGoalCompleted)
        case .beltPromoted:
            return award(.firstBeltPromotion)
        case .classCheckedIn(let totalCount, let isPerfectWeek, let consecutivePerfectWeeks):
            return checkAttendanceAchievements(totalCount: totalCount, isPerfectWeek: isPerfectWeek, consecutivePerfectWeeks: consecutivePerfectWeeks)
        default:
            return []
        }
    }

    // MARK: - Wipe

    func clearAll() {
        logOut()
        try? localService.deleteAll()
        earnedAchievements = []
        BJJSyncHelper.clearSyncTimestamp(key: BJJSyncHelper.achievementsSyncKey)
    }

    // MARK: - Private

    private func syncFromRemote(userId: String) async {
        do {
            let remoteModels = try await remoteService.getAchievements(userId: userId)
            let localIds = Set(earnedAchievements.map { $0.achievementEarnedId })
            var changed = false
            for model in remoteModels where !localIds.contains(model.achievementEarnedId) {
                try? localService.create(model)
                changed = true
            }
            if changed { refresh() }
            BJJSyncHelper.markSynced(key: BJJSyncHelper.achievementsSyncKey)
        } catch {
            logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "AchievementManager", context: "Sync", error: error))
        }
    }

    private func checkSessionAchievements(totalCount: Int, streak: Int) -> [AchievementId] {
        var achievements: [AchievementId] = []
        if totalCount == 1 { achievements += award(.firstSession) }
        if totalCount == 10 { achievements += award(.tenSessions) }
        if totalCount == 50 { achievements += award(.fiftySessions) }
        if totalCount == 100 { achievements += award(.hundredSessions) }
        if streak >= 3 { achievements += award(.threeDayStreak) }
        if streak >= 7 { achievements += award(.sevenDayStreak) }
        if streak >= 30 { achievements += award(.thirtyDayStreak) }
        return achievements
    }

    private func checkAttendanceAchievements(totalCount: Int, isPerfectWeek: Bool, consecutivePerfectWeeks: Int) -> [AchievementId] {
        var achievements: [AchievementId] = []
        if totalCount == 1 { achievements += award(.firstClassCheckedIn) }
        if totalCount == 5 { achievements += award(.fiveClassAttendance) }
        if totalCount == 25 { achievements += award(.twentyFiveClassAttendance) }
        if isPerfectWeek { achievements += award(.perfectWeek) }
        if consecutivePerfectWeeks >= 4 { achievements += award(.fourWeekConsistency) }
        return achievements
    }

    private func award(_ id: AchievementId) -> [AchievementId] {
        guard !isEarned(id) else { return [] }
        let model = AchievementEarnedModel(achievementId: id.rawValue)
        try? localService.create(model)
        refresh()
        syncToRemote(model)
        return [id]
    }

    private func syncToRemote(_ model: AchievementEarnedModel) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.saveAchievement(model, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "AchievementManager", context: "Save", error: error))
            }
        }
    }
}
