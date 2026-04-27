import SwiftUI

@MainActor
protocol ProfileInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var sessionStats: SessionStats { get }
    var isPremium: Bool { get }
    var currentStreakData: CurrentStreakData { get }
    var currentExperiencePointsData: CurrentExperiencePointsData { get }
}

extension CoreInteractor: ProfileInteractor { }
