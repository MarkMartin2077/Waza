import SwiftUI

@MainActor
protocol DashboardInteractor: GlobalInteractor {
    var recentSessions: [BJJSessionModel] { get }
    var sessionStats: SessionStats { get }
    var currentBeltEnum: BJJBelt { get }
    var currentUserName: String { get }
    var currentStreakData: CurrentStreakData { get }
    var currentExperiencePointsData: CurrentExperiencePointsData { get }
    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? { get }
    var gyms: [GymLocationModel] { get }
    var trainingGoalPerWeek: Int? { get }
    var currentChallenges: [WeeklyChallengeModel] { get }
    var completedChallengeCount: Int { get }
    func generateChallengesIfNeeded()
    func endTrainingLiveActivity() async
    func updateWidgetData(_ data: WazaWidgetData)
    func useStreakFreezes() async throws
}

extension CoreInteractor: DashboardInteractor { }
