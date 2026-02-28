import Foundation
import IdentifiableByString

struct ClassScheduleModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var scheduleId: String
    var gymId: String
    var name: String
    var dayOfWeek: Int          // 1 = Sunday … 7 = Saturday (Calendar.weekday)
    var startHour: Int          // 0-23
    var startMinute: Int        // 0-59
    var durationMinutes: Int
    var sessionType: SessionType
    var reminderMinutesBefore: Int
    var isActive: Bool
    var createdDate: Date

    var id: String { scheduleId }

    init(
        scheduleId: String = UUID().uuidString,
        gymId: String,
        name: String,
        dayOfWeek: Int,
        startHour: Int,
        startMinute: Int,
        durationMinutes: Int = 60,
        sessionType: SessionType = .gi,
        reminderMinutesBefore: Int = 30,
        isActive: Bool = true,
        createdDate: Date = Date()
    ) {
        self.scheduleId = scheduleId
        self.gymId = gymId
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.startHour = startHour
        self.startMinute = startMinute
        self.durationMinutes = durationMinutes
        self.sessionType = sessionType
        self.reminderMinutesBefore = reminderMinutesBefore
        self.isActive = isActive
        self.createdDate = createdDate
    }

    init(entity: ClassScheduleEntity) {
        self.scheduleId = entity.scheduleId
        self.gymId = entity.gymId
        self.name = entity.name
        self.dayOfWeek = entity.dayOfWeek
        self.startHour = entity.startHour
        self.startMinute = entity.startMinute
        self.durationMinutes = entity.durationMinutes
        self.sessionType = SessionType(rawValue: entity.sessionTypeRaw) ?? .gi
        self.reminderMinutesBefore = entity.reminderMinutesBefore
        self.isActive = entity.isActive
        self.createdDate = entity.createdDate
    }

    func toEntity() -> ClassScheduleEntity {
        ClassScheduleEntity(from: self)
    }

    // MARK: - Computed

    /// Next future occurrence of this class.
    var nextOccurrence: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = dayOfWeek
        components.hour = startHour
        components.minute = startMinute
        components.second = 0
        guard var candidate = calendar.date(from: components) else { return now }
        if candidate <= now {
            candidate = calendar.date(byAdding: .weekOfYear, value: 1, to: candidate) ?? candidate
        }
        return candidate
    }

    /// Human-readable summary e.g. "Mon 7:00 PM · 60 min"
    var formattedTime: String {
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let day = dayOfWeek >= 1 && dayOfWeek <= 7 ? dayNames[dayOfWeek] : "?"
        let hour12 = startHour == 0 ? 12 : (startHour > 12 ? startHour - 12 : startHour)
        let ampm = startHour < 12 ? "AM" : "PM"
        let minute = String(format: "%02d", startMinute)
        return "\(day) \(hour12):\(minute) \(ampm) · \(durationMinutes) min"
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case scheduleId = "schedule_id"
        case gymId = "gym_id"
        case name
        case dayOfWeek = "day_of_week"
        case startHour = "start_hour"
        case startMinute = "start_minute"
        case durationMinutes = "duration_minutes"
        case sessionType = "session_type"
        case reminderMinutesBefore = "reminder_minutes_before"
        case isActive = "is_active"
        case createdDate = "created_date"
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "schedule_id": scheduleId,
            "gym_id": gymId,
            "day_of_week": dayOfWeek,
            "session_type": sessionType.rawValue
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension ClassScheduleModel {
    static var mock: ClassScheduleModel {
        ClassScheduleModel(
            scheduleId: "mock-schedule-1",
            gymId: "mock-gym-1",
            name: "Monday Gi",
            dayOfWeek: 2,
            startHour: 19,
            startMinute: 0,
            durationMinutes: 90,
            sessionType: .gi,
            reminderMinutesBefore: 30
        )
    }

    static var mocks: [ClassScheduleModel] {
        [
            mock,
            ClassScheduleModel(
                scheduleId: "mock-schedule-2",
                gymId: "mock-gym-1",
                name: "Wednesday No-Gi",
                dayOfWeek: 4,
                startHour: 18,
                startMinute: 30,
                durationMinutes: 60,
                sessionType: .noGi,
                reminderMinutesBefore: 30
            ),
            ClassScheduleModel(
                scheduleId: "mock-schedule-3",
                gymId: "mock-gym-1",
                name: "Saturday Open Mat",
                dayOfWeek: 7,
                startHour: 10,
                startMinute: 0,
                durationMinutes: 120,
                sessionType: .openMat,
                reminderMinutesBefore: 60
            )
        ]
    }
}
