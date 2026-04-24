import SwiftUI

@MainActor
protocol TrainingStatsRouter: GlobalRouter {
    func showGoalsPlanningView()
    func showAIInsightsView()
    func showAchievementsView()
    func showMonthlyReportView()
}

extension CoreRouter: TrainingStatsRouter { }
