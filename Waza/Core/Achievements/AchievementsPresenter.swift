import SwiftUI

struct AchievementSection {
    let category: AchievementCategory
    let achievements: [AchievementId]
}

@Observable
@MainActor
class AchievementsPresenter {
    private let interactor: AchievementsInteractor
    private let router: AchievementsRouter

    private(set) var earnedAchievements: [AchievementEarnedModel] = []
    private(set) var sessionStats: SessionStats = .empty
    private(set) var streakCount: Int = 0
    private(set) var attendanceCount: Int = 0
    private(set) var completedGoalCount: Int = 0
    var selectedAchievement: AchievementId?

    var sections: [AchievementSection] {
        AchievementCategory.allCases.compactMap { category in
            let achievements = AchievementId.allCases.filter { $0.category == category }
            guard !achievements.isEmpty else { return nil }
            return AchievementSection(category: category, achievements: achievements)
        }
    }

    var earnedCount: Int { earnedAchievements.count }
    var totalCount: Int { AchievementId.allCases.count }

    init(interactor: AchievementsInteractor, router: AchievementsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
    }

    func onAchievementTapped(_ id: AchievementId) {
        interactor.trackEvent(event: Event.achievementTapped)
        selectedAchievement = id
    }

    func isEarned(_ id: AchievementId) -> Bool {
        earnedAchievements.contains { $0.achievementId == id.rawValue }
    }

    func earnedDate(for id: AchievementId) -> Date? {
        earnedAchievements.first { $0.achievementId == id.rawValue }?.earnedDate
    }

    private func loadData() {
        earnedAchievements = interactor.earnedAchievements
        sessionStats = interactor.sessionStats
        streakCount = interactor.currentStreakData.currentStreak ?? 0
        attendanceCount = interactor.classAttendance.count
        completedGoalCount = interactor.completedGoals.count
    }

    func progressHint(for achievementId: AchievementId) -> String? {
        guard !isEarned(achievementId) else { return nil }
        return achievementId.progressHint(
            totalSessions: sessionStats.totalSessions,
            thisWeekSessions: sessionStats.thisWeekSessions,
            streakCount: streakCount,
            attendanceCount: attendanceCount
        )
    }
}

extension AchievementsPresenter {

    enum Event: LoggableEvent {
        case onAppear
        case achievementTapped

        var eventName: String {
            switch self {
            case .onAppear:        return "AchievementsView_Appear"
            case .achievementTapped: return "AchievementsView_Achievement_Tap"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }

}
