import SwiftData
import Foundation

@Observable
@MainActor
class GoalManager {
    private let modelContext: ModelContext

    private(set) var goals: [TrainingGoalModel] = []

    var activeGoals: [TrainingGoalModel] {
        goals.filter { !$0.isCompleted }
    }

    var completedGoals: [TrainingGoalModel] {
        goals.filter { $0.isCompleted }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<TrainingGoalModel>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        goals = (try? modelContext.fetch(descriptor)) ?? []
    }

    @discardableResult
    func createGoal(
        title: String,
        description: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil
    ) throws -> TrainingGoalModel {
        let goal = TrainingGoalModel(
            title: title,
            goalDescription: description,
            goalType: goalType,
            deadline: deadline
        )
        modelContext.insert(goal)
        try modelContext.save()
        refresh()
        return goal
    }

    func updateProgress(goalId: String, progress: Double) throws {
        guard let goal = goals.first(where: { $0.id == goalId }) else { return }
        goal.progress = min(max(progress, 0), 1.0)
        if goal.progress >= 1.0 && !goal.isCompleted {
            goal.isCompleted = true
            goal.completedDate = Date()
        }
        try modelContext.save()
        refresh()
    }

    func completeGoal(goalId: String) throws {
        guard let goal = goals.first(where: { $0.id == goalId }) else { return }
        goal.isCompleted = true
        goal.progress = 1.0
        goal.completedDate = Date()
        try modelContext.save()
        refresh()
    }

    func updateGoal(_ goal: TrainingGoalModel) throws {
        try modelContext.save()
        refresh()
    }

    func deleteGoal(_ goal: TrainingGoalModel) throws {
        modelContext.delete(goal)
        try modelContext.save()
        refresh()
    }

    func seedMockDataIfEmpty() {
        guard goals.isEmpty else { return }
        for goal in TrainingGoalModel.mocks {
            modelContext.insert(goal)
        }
        try? modelContext.save()
        refresh()
    }
}
