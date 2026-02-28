import SwiftUI

@MainActor
protocol CheckInInteractor: GlobalInteractor {
    func checkIn(gymId: String, scheduleId: String?, method: CheckInMethod, moodRating: Int?) throws -> ClassAttendanceModel
    func updateAttendance(_ record: ClassAttendanceModel) throws
    func generateCheckInEncouragement(streakCount: Int, classesThisWeek: Int, weeklyTarget: Int, belt: BJJBelt, totalAttendance: Int) -> AsyncThrowingStream<String, Error>
    var currentStreakData: CurrentStreakData { get }
    var currentBeltEnum: BJJBelt { get }
    var classAttendance: [ClassAttendanceModel] { get }
    func weeklyAttendanceCount(weekOf: Date) -> Int
}

extension CoreInteractor: CheckInInteractor { }
