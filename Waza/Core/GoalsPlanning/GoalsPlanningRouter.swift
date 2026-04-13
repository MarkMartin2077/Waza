import SwiftUI

@MainActor
protocol GoalsPlanningRouter: GlobalRouter {
    func showAddGoalSheet(focusAreaOptions: [String], onSave: @escaping (GoalMetric, Int, String?) -> Void)
}

extension CoreRouter: GoalsPlanningRouter { }
