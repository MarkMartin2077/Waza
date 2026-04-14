import SwiftUI

@MainActor
protocol ProfileInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var currentBelt: BeltRecordModel? { get }
    var currentBeltEnum: BJJBelt { get }
    var beltHistory: [BeltRecordModel] { get }
    var sessionStats: SessionStats { get }
    var earnedAchievements: [AchievementEarnedModel] { get }
    var isPremium: Bool { get }
    var gyms: [GymLocationModel] { get }
    var schedules: [ClassScheduleModel] { get }
    var classAttendance: [ClassAttendanceModel] { get }
    var currentStreakData: CurrentStreakData { get }
    var currentExperiencePointsData: CurrentExperiencePointsData { get }
    func setInitialBelt(belt: BJJBelt, stripes: Int, date: Date, academy: String?, notes: String?) throws
    func addBeltPromotion(belt: BJJBelt, stripes: Int, date: Date, academy: String?, notes: String?) throws -> BeltRecordModel
    func saveUserProfileImage(image: UIImage) async throws
}

extension CoreInteractor: ProfileInteractor { }
