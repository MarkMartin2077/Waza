import Foundation

@MainActor
protocol GoalServices {
    var local: GoalLocalService { get }
    var remote: RemoteGoalService { get }
}

@MainActor
struct MockGoalServices: GoalServices {
    let local: GoalLocalService = SwiftDataGoalPersistence(inMemory: true)
    let remote: RemoteGoalService = MockRemoteGoalService()
}

@MainActor
struct ProductionGoalServices: GoalServices {
    let local: GoalLocalService = SwiftDataGoalPersistence()
    let remote: RemoteGoalService = FirebaseGoalService()
}
