import SwiftUI

@MainActor
protocol TabBarInteractor: GlobalInteractor {
    var gyms: [GymLocationModel] { get }
    var lastUnlockedAchievement: AchievementId? { get }
    func closestSchedule(forGymId gymId: String, at date: Date) -> ClassScheduleModel?
    func consumeUnlockedAchievement()
}

extension CoreInteractor: TabBarInteractor { }
