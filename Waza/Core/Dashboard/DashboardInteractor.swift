import SwiftUI

@MainActor
protocol DashboardInteractor: GlobalInteractor {
    var recentSessions: [BJJSessionModel] { get }
    var sessionStats: SessionStats { get }
    var currentBelt: BeltRecordModel? { get }
    var currentBeltEnum: BJJBelt { get }
    var activeGoals: [TrainingGoalModel] { get }
    var currentStreakData: CurrentStreakData { get }
    var currentExperiencePointsData: CurrentExperiencePointsData { get }
    var isPremium: Bool { get }
    var isAIAvailable: Bool { get }
    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? { get }
    var gyms: [GymLocationModel] { get }
    var schedules: [ClassScheduleModel] { get }
    func weeklyAttendanceCount(weekOf: Date) -> Int
}

extension CoreInteractor: DashboardInteractor { }
