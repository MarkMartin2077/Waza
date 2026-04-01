import SwiftUI

@MainActor
protocol CheckInInteractor: GlobalInteractor {
    func checkIn(gymId: String, scheduleId: String?, method: CheckInMethod, moodRating: Int?) throws -> ClassAttendanceModel
    func updateAttendance(_ record: ClassAttendanceModel) throws
    var currentUserName: String { get }
    func generateCheckInEncouragement(context: AIEncouragementContext) -> AsyncThrowingStream<String, Error>
    var currentStreakData: CurrentStreakData { get }
    var currentBeltEnum: BJJBelt { get }
    var classAttendance: [ClassAttendanceModel] { get }
    func weeklyAttendanceCount(weekOf: Date) -> Int
    func startTrainingLiveActivity(sessionTypeDisplayName: String, gymName: String?, beltAccentColorHex: String)
    var trainingGoalPerWeek: Int? { get }
}

extension CoreInteractor: CheckInInteractor { }
