import SwiftUI

@MainActor
protocol ProfileInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var sessionStats: SessionStats { get }
    var isPremium: Bool { get }
    var currentStreakData: CurrentStreakData { get }
    var currentExperiencePointsData: CurrentExperiencePointsData { get }
    func saveUserProfileImage(image: UIImage) async throws
}

extension CoreInteractor: ProfileInteractor { }
