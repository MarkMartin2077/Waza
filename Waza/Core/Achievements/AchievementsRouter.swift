import SwiftUI

@MainActor
protocol AchievementsRouter: GlobalRouter {
    func showAchievementDetail(achievementId: AchievementId, isEarned: Bool, earnedDate: Date?, progressHint: String?)
}

extension CoreRouter: AchievementsRouter { }
