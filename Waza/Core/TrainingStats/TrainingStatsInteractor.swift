import SwiftUI

@MainActor
protocol TrainingStatsInteractor: GlobalInteractor {
    var activeGoals: [TrainingGoalModel] { get }
    var isAIAvailable: Bool { get }
    var earnedAchievements: [AchievementEarnedModel] { get }
    var currentBeltEnum: BJJBelt { get }
    var beltHistory: [BeltRecordModel] { get }
    var sessionStats: SessionStats { get }
    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot
    func getTypeBreakdown(for period: DateRange) -> [TypeStat]
    func computeProgress(for goal: TrainingGoalModel) -> Double
    func currentValue(for goal: TrainingGoalModel) -> Double
}

extension CoreInteractor: TrainingStatsInteractor { }
