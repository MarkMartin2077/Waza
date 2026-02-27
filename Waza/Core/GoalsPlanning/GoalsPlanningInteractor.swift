import SwiftUI

@MainActor
protocol GoalsPlanningInteractor: GlobalInteractor {
    var activeGoals: [TrainingGoalModel] { get }
    var completedGoals: [TrainingGoalModel] { get }
    var currentBeltEnum: BJJBelt { get }
    func createGoal(title: String, description: String?, goalType: GoalType, deadline: Date?) throws -> TrainingGoalModel
    func updateGoalProgress(goalId: String, progress: Double) throws
    func completeGoal(goalId: String) throws
    func updateGoal(_ goal: TrainingGoalModel) throws
    func deleteGoal(_ goal: TrainingGoalModel) throws
}

extension CoreInteractor: GoalsPlanningInteractor { }
