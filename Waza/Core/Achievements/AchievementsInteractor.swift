import SwiftUI

@MainActor
protocol AchievementsInteractor: GlobalInteractor {
    var earnedAchievements: [AchievementEarnedModel] { get }
}

extension CoreInteractor: AchievementsInteractor { }
