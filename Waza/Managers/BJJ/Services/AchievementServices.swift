import Foundation

@MainActor
protocol AchievementServices {
    var local: AchievementLocalService { get }
    var remote: RemoteAchievementService { get }
}

@MainActor
struct MockAchievementServices: AchievementServices {
    let local: AchievementLocalService = SwiftDataAchievementPersistence(inMemory: true)
    let remote: RemoteAchievementService = MockRemoteAchievementService()
}

@MainActor
struct ProductionAchievementServices: AchievementServices {
    let local: AchievementLocalService = SwiftDataAchievementPersistence()
    let remote: RemoteAchievementService = FirebaseAchievementService()
}
