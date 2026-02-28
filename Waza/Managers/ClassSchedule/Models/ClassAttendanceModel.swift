import Foundation
import IdentifiableByString

struct ClassAttendanceModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var attendanceId: String
    var gymId: String
    var scheduleId: String?
    var checkInDate: Date
    var checkInMethod: CheckInMethod
    var moodRating: Int?
    var linkedSessionId: String?
    var aiEncouragement: String?

    var id: String { attendanceId }

    init(
        attendanceId: String = UUID().uuidString,
        gymId: String,
        scheduleId: String? = nil,
        checkInDate: Date = Date(),
        checkInMethod: CheckInMethod = .manual,
        moodRating: Int? = nil,
        linkedSessionId: String? = nil,
        aiEncouragement: String? = nil
    ) {
        self.attendanceId = attendanceId
        self.gymId = gymId
        self.scheduleId = scheduleId
        self.checkInDate = checkInDate
        self.checkInMethod = checkInMethod
        self.moodRating = moodRating
        self.linkedSessionId = linkedSessionId
        self.aiEncouragement = aiEncouragement
    }

    init(entity: ClassAttendanceEntity) {
        self.attendanceId = entity.attendanceId
        self.gymId = entity.gymId
        self.scheduleId = entity.scheduleId
        self.checkInDate = entity.checkInDate
        self.checkInMethod = CheckInMethod(rawValue: entity.checkInMethodRaw) ?? .manual
        self.moodRating = entity.moodRating
        self.linkedSessionId = entity.linkedSessionId
        self.aiEncouragement = entity.aiEncouragement
    }

    func toEntity() -> ClassAttendanceEntity {
        ClassAttendanceEntity(from: self)
    }

    // MARK: - Computed

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: checkInDate)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case attendanceId = "attendance_id"
        case gymId = "gym_id"
        case scheduleId = "schedule_id"
        case checkInDate = "check_in_date"
        case checkInMethod = "check_in_method"
        case moodRating = "mood_rating"
        case linkedSessionId = "linked_session_id"
        case aiEncouragement = "ai_encouragement"
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "attendance_id": attendanceId,
            "gym_id": gymId,
            "check_in_method": checkInMethod.rawValue,
            "mood_rating": moodRating
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension ClassAttendanceModel {
    static var mock: ClassAttendanceModel {
        ClassAttendanceModel(
            attendanceId: "mock-attendance-1",
            gymId: "mock-gym-1",
            scheduleId: "mock-schedule-1",
            checkInDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            checkInMethod: .manual,
            moodRating: 4
        )
    }

    static var mocks: [ClassAttendanceModel] {
        (0..<12).map { offset in
            ClassAttendanceModel(
                attendanceId: "mock-attendance-\(offset)",
                gymId: "mock-gym-1",
                scheduleId: "mock-schedule-1",
                checkInDate: Calendar.current.date(byAdding: .day, value: -(offset * 3), to: Date()) ?? Date(),
                checkInMethod: offset % 3 == 0 ? .geofence : .manual,
                moodRating: [3, 4, 5][offset % 3]
            )
        }
    }
}
