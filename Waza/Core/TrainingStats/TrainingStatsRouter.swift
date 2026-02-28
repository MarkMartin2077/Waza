import SwiftUI

@MainActor
protocol TrainingStatsRouter: GlobalRouter {
    func showGoalsPlanningView()
}

extension CoreRouter: TrainingStatsRouter { }
