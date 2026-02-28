import Foundation

@MainActor
protocol RemoteAchievementService: Sendable {
    func getAchievements(userId: String) async throws -> [AchievementEarnedModel]
    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws
}
