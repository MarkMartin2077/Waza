import Foundation

@MainActor
protocol ClassScheduleServices {
    var gymLocation: GymLocationLocalService { get }
    var schedule: ClassScheduleLocalService { get }
    var attendance: ClassAttendanceLocalService { get }
}

@MainActor
struct MockClassScheduleServices: ClassScheduleServices {
    let gymLocation: GymLocationLocalService = SwiftDataGymLocationPersistence(inMemory: true)
    let schedule: ClassScheduleLocalService = SwiftDataClassSchedulePersistence(inMemory: true)
    let attendance: ClassAttendanceLocalService = SwiftDataClassAttendancePersistence(inMemory: true)
}

@MainActor
struct ProductionClassScheduleServices: ClassScheduleServices {
    let gymLocation: GymLocationLocalService = SwiftDataGymLocationPersistence()
    let schedule: ClassScheduleLocalService = SwiftDataClassSchedulePersistence()
    let attendance: ClassAttendanceLocalService = SwiftDataClassAttendancePersistence()
}
