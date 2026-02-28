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
    func setInitialBelt(belt: BJJBelt, stripes: Int, date: Date, academy: String?, notes: String?) throws
    func addBeltPromotion(belt: BJJBelt, stripes: Int, date: Date, academy: String?, notes: String?) throws -> BeltRecordModel
}

extension CoreInteractor: ProfileInteractor { }
