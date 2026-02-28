import Foundation

@MainActor
final class MockRemoteAchievementService: RemoteAchievementService {
    var achievements: [AchievementEarnedModel]

    init(achievements: [AchievementEarnedModel] = []) {
        self.achievements = achievements
    }

    func getAchievements(userId: String) async throws -> [AchievementEarnedModel] {
        achievements
    }

    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws {
        if !achievements.contains(where: { $0.achievementEarnedId == model.achievementEarnedId }) {
            achievements.append(model)
        }
    }
}
