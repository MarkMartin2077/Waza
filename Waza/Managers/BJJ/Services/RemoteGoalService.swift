import Foundation

// MARK: - Remote Service Protocol

@MainActor
protocol RemoteGoalService: Sendable {
    func getGoals(userId: String) async throws -> [TrainingGoalModel]
    func saveGoal(_ model: TrainingGoalModel, userId: String) async throws
    func deleteGoal(id: String, userId: String) async throws
}

// MARK: - Firebase Implementation

@MainActor
struct FirebaseGoalService: RemoteGoalService {
    private let collectionPath = "training_goals"

    func getGoals(userId: String) async throws -> [TrainingGoalModel] {
        // TODO: Implement using SwiftfulFirestore helpers
        return []
    }

    func saveGoal(_ model: TrainingGoalModel, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
    }

    func deleteGoal(id: String, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
    }
}

// MARK: - Mock Implementation

@MainActor
final class MockRemoteGoalService: RemoteGoalService {
    var goals: [TrainingGoalModel] = []

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
