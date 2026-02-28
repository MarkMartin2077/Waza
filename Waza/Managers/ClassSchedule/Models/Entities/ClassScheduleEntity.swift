import SwiftData
import Foundation

@Model
final class ClassScheduleEntity {
    @Attribute(.unique) var scheduleId: String
    var gymId: String
    var name: String
    var dayOfWeek: Int
    var startHour: Int
    var startMinute: Int
    var durationMinutes: Int
    var sessionTypeRaw: String
    var reminderMinutesBefore: Int
    var isActive: Bool
    var createdDate: Date

    init(
        scheduleId: String = UUID().uuidString,
        gymId: String = "",
        name: String = "",
        dayOfWeek: Int = 2,
        startHour: Int = 19,
        startMinute: Int = 0,
        durationMinutes: Int = 60,
        sessionTypeRaw: String = "gi",
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
        self.sessionTypeRaw = sessionTypeRaw
        self.reminderMinutesBefore = reminderMinutesBefore
        self.isActive = isActive
        self.createdDate = createdDate
    }

    convenience init(from model: ClassScheduleModel) {
        self.init(
            scheduleId: model.scheduleId,
            gymId: model.gymId,
            name: model.name,
            dayOfWeek: model.dayOfWeek,
            startHour: model.startHour,
            startMinute: model.startMinute,
            durationMinutes: model.durationMinutes,
            sessionTypeRaw: model.sessionType.rawValue,
            reminderMinutesBefore: model.reminderMinutesBefore,
            isActive: model.isActive,
            createdDate: model.createdDate
        )
    }

    func toModel() -> ClassScheduleModel {
        ClassScheduleModel(entity: self)
    }

    func update(from model: ClassScheduleModel) {
        gymId = model.gymId
        name = model.name
        dayOfWeek = model.dayOfWeek
        startHour = model.startHour
        startMinute = model.startMinute
        durationMinutes = model.durationMinutes
        sessionTypeRaw = model.sessionType.rawValue
        reminderMinutesBefore = model.reminderMinutesBefore
        isActive = model.isActive
    }
}
