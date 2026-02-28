import Foundation

@MainActor
final class MockRemoteGoalService: RemoteGoalService {
    var goals: [TrainingGoalModel]

    init(goals: [TrainingGoalModel] = []) {
        self.goals = goals
    }

    func getGoals(userId: String) async throws -> [TrainingGoalModel] {
        goals
    }

    func saveGoal(_ model: TrainingGoalModel, userId: String) async throws {
        if let index = goals.firstIndex(where: { $0.goalId == model.goalId }) {
            goals[index] = model
        } else {
            goals.append(model)
        }
    }

    func deleteGoal(id: String, userId: String) async throws {
        goals.removeAll { $0.goalId == id }
    }
}
