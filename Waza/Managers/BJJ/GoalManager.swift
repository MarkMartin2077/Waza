import Foundation

@Observable
@MainActor
class GoalManager {
    private let localService: GoalLocalService
    private let remoteService: RemoteGoalService

    private(set) var goals: [TrainingGoalModel] = []

    var activeGoals: [TrainingGoalModel] {
        goals.filter { !$0.isCompleted }
    }

    var completedGoals: [TrainingGoalModel] {
        goals.filter { $0.isCompleted }
    }

    init(services: GoalServices) {
        self.localService = services.local
        self.remoteService = services.remote
        refresh()
    }

    func refresh() {
        goals = localService.getGoals()
    }

    @discardableResult
    func createGoal(
        title: String,
        description: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil
    ) throws -> TrainingGoalModel {
        let model = TrainingGoalModel(
            title: title,
            goalDescription: description,
            goalType: goalType,
            deadline: deadline
        )
        try localService.create(model)
        refresh()
        return model
    }

    func updateProgress(goalId: String, progress: Double) throws {
        guard var goal = goals.first(where: { $0.goalId == goalId }) else { return }
        goal.progress = min(max(progress, 0), 1.0)
        if goal.progress >= 1.0 && !goal.isCompleted {
            goal.isCompleted = true
            goal.completedDate = Date()
        }
        try localService.update(goal)
        refresh()
    }

    func completeGoal(goalId: String) throws {
        guard var goal = goals.first(where: { $0.goalId == goalId }) else { return }
        goal.isCompleted = true
        goal.progress = 1.0
        goal.completedDate = Date()
        try localService.update(goal)
        refresh()
    }

    func updateGoal(_ model: TrainingGoalModel) throws {
        try localService.update(model)
        refresh()
    }

    func deleteGoal(_ model: TrainingGoalModel) throws {
        try localService.delete(id: model.goalId)
        refresh()
    }

    func seedMockDataIfEmpty() {
        guard goals.isEmpty else { return }
        for model in TrainingGoalModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }
}
