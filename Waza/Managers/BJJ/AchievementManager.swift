import SwiftData
import Foundation

@Observable
@MainActor
class AchievementManager {
    private let modelContext: ModelContext

    private(set) var earnedAchievements: [AchievementEarnedModel] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<AchievementEarnedModel>(
            sortBy: [SortDescriptor(\.earnedDate, order: .reverse)]
        )
        earnedAchievements = (try? modelContext.fetch(descriptor)) ?? []
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

    private func award(_ id: AchievementId) -> [AchievementId] {
        guard !isEarned(id) else { return [] }
        let achievement = AchievementEarnedModel(achievementId: id.rawValue)
        modelContext.insert(achievement)
        try? modelContext.save()
        refresh()
        return [id]
    }
}
