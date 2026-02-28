import Foundation

@MainActor
protocol RemoteGoalService: Sendable {
    func getGoals(userId: String) async throws -> [TrainingGoalModel]
    func saveGoal(_ model: TrainingGoalModel, userId: String) async throws
    func deleteGoal(id: String, userId: String) async throws
}
