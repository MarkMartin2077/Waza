import Foundation

@Observable
@MainActor
class AchievementManager {
    private let localService: AchievementLocalService
    private let remoteService: RemoteAchievementService

    private(set) var earnedAchievements: [AchievementEarnedModel] = []

    init(services: AchievementServices) {
        self.localService = services.local
        self.remoteService = services.remote
        refresh()
    }

    func refresh() {
        earnedAchievements = localService.getAchievements()
    }

    func isEarned(_ id: AchievementId) -> Bool {
        earnedAchievements.contains { $0.achievementId == id.rawValue }
    }

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
        return [id]
    }
}
