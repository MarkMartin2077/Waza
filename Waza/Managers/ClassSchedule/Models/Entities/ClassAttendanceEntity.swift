import SwiftData
import Foundation

@Model
final class ClassAttendanceEntity {
    @Attribute(.unique) var attendanceId: String
    var gymId: String
    var scheduleId: String?
    var checkInDate: Date
    var checkInMethodRaw: String
    var moodRating: Int?
    var linkedSessionId: String?
    var aiEncouragement: String?

    init(
        attendanceId: String = UUID().uuidString,
        gymId: String = "",
        scheduleId: String? = nil,
        checkInDate: Date = Date(),
        checkInMethodRaw: String = "manual",
        moodRating: Int? = nil,
        linkedSessionId: String? = nil,
        aiEncouragement: String? = nil
    ) {
        self.attendanceId = attendanceId
        self.gymId = gymId
        self.scheduleId = scheduleId
        self.checkInDate = checkInDate
        self.checkInMethodRaw = checkInMethodRaw
        self.moodRating = moodRating
        self.linkedSessionId = linkedSessionId
        self.aiEncouragement = aiEncouragement
    }

    convenience init(from model: ClassAttendanceModel) {
        self.init(
            attendanceId: model.attendanceId,
            gymId: model.gymId,
            scheduleId: model.scheduleId,
            checkInDate: model.checkInDate,
            checkInMethodRaw: model.checkInMethod.rawValue,
            moodRating: model.moodRating,
            linkedSessionId: model.linkedSessionId,
            aiEncouragement: model.aiEncouragement
        )
    }

    func toModel() -> ClassAttendanceModel {
        ClassAttendanceModel(entity: self)
    }

    func update(from model: ClassAttendanceModel) {
        gymId = model.gymId
        scheduleId = model.scheduleId
        checkInDate = model.checkInDate
        checkInMethodRaw = model.checkInMethod.rawValue
        moodRating = model.moodRating
        linkedSessionId = model.linkedSessionId
        aiEncouragement = model.aiEncouragement
    }
}
