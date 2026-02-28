import SwiftUI

@MainActor
protocol TrainingStatsInteractor: GlobalInteractor {
    var trainingStatsManager: TrainingStatsManager { get }
    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot
    func getCLAStatSummary() -> CLAStatSummary
    func getTypeBreakdown(for period: DateRange) -> [TypeStat]
}

extension CoreInteractor: TrainingStatsInteractor { }
