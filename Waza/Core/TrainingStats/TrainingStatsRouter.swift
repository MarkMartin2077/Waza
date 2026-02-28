import SwiftUI

@MainActor
protocol TrainingStatsRouter: GlobalRouter {
    func showGoalsPlanningView()
    func showAIInsightsView()
}

extension CoreRouter: TrainingStatsRouter { }
