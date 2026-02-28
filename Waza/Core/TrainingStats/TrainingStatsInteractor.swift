import SwiftUI

@MainActor
protocol TrainingStatsInteractor: GlobalInteractor {
    var trainingStatsManager: TrainingStatsManager { get }
    var activeGoals: [TrainingGoalModel] { get }
    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot
    func getTypeBreakdown(for period: DateRange) -> [TypeStat]
}

extension CoreInteractor: TrainingStatsInteractor { }
