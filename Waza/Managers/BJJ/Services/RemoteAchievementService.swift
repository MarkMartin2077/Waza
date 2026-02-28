import Foundation

// MARK: - Remote Service Protocol

@MainActor
protocol RemoteAchievementService: Sendable {
    func getAchievements(userId: String) async throws -> [AchievementEarnedModel]
    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws
}

// MARK: - Firebase Implementation

@MainActor
struct FirebaseAchievementService: RemoteAchievementService {
    private let collectionPath = "achievements_earned"

    func getAchievements(userId: String) async throws -> [AchievementEarnedModel] {
        // TODO: Implement using SwiftfulFirestore helpers
        return []
    }

    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
    }
}

// MARK: - Mock Implementation

@MainActor
final class MockRemoteAchievementService: RemoteAchievementService {
    var achievements: [AchievementEarnedModel] = []

    func getAchievements(userId: String) async throws -> [AchievementEarnedModel] {
        achievements
    }

    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws {
        if !achievements.contains(where: { $0.achievementEarnedId == model.achievementEarnedId }) {
            achievements.append(model)
        }
    }
}
