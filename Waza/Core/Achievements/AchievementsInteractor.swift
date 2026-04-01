import SwiftUI

@MainActor
protocol AchievementsInteractor: GlobalInteractor {
    var earnedAchievements: [AchievementEarnedModel] { get }
    var sessionStats: SessionStats { get }
    var currentStreakData: CurrentStreakData { get }
    var classAttendance: [ClassAttendanceModel] { get }
    var completedGoals: [TrainingGoalModel] { get }
}

extension CoreInteractor: AchievementsInteractor { }
