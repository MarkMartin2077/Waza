import SwiftData
import Foundation

// MARK: - Gym Location Local Service

@MainActor
protocol GymLocationLocalService {
    func getGyms() -> [GymLocationModel]
    func create(_ model: GymLocationModel) throws
    func update(_ model: GymLocationModel) throws
    func delete(id: String) throws
    func deleteAll() throws
}

@MainActor
struct SwiftDataGymLocationPersistence: GymLocationLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("GymLocations", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: GymLocationEntity.self, configurations: config)
    }

    func getGyms() -> [GymLocationModel] {
        let descriptor = FetchDescriptor<GymLocationEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: GymLocationModel) throws {
        let entity = GymLocationEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ model: GymLocationModel) throws {
        let idToMatch = model.gymId
        let descriptor = FetchDescriptor<GymLocationEntity>(
            predicate: #Predicate { $0.gymId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: model)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<GymLocationEntity>(
            predicate: #Predicate { $0.gymId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: GymLocationEntity.self)
        try container.mainContext.save()
    }
}

// MARK: - Class Schedule Local Service

@MainActor
protocol ClassScheduleLocalService {
    func getSchedules() -> [ClassScheduleModel]
    func create(_ model: ClassScheduleModel) throws
    func update(_ model: ClassScheduleModel) throws
    func delete(id: String) throws
    func deleteAll() throws
}

@MainActor
struct SwiftDataClassSchedulePersistence: ClassScheduleLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("ClassSchedules", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: ClassScheduleEntity.self, configurations: config)
    }

    func getSchedules() -> [ClassScheduleModel] {
        let descriptor = FetchDescriptor<ClassScheduleEntity>(
            sortBy: [SortDescriptor(\.dayOfWeek), SortDescriptor(\.startHour), SortDescriptor(\.startMinute)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: ClassScheduleModel) throws {
        let entity = ClassScheduleEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ model: ClassScheduleModel) throws {
        let idToMatch = model.scheduleId
        let descriptor = FetchDescriptor<ClassScheduleEntity>(
            predicate: #Predicate { $0.scheduleId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: model)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<ClassScheduleEntity>(
            predicate: #Predicate { $0.scheduleId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: ClassScheduleEntity.self)
        try container.mainContext.save()
    }
}

// MARK: - Class Attendance Local Service

@MainActor
protocol ClassAttendanceLocalService {
    func getAttendance() -> [ClassAttendanceModel]
    func create(_ model: ClassAttendanceModel) throws
    func update(_ model: ClassAttendanceModel) throws
    func delete(id: String) throws
    func deleteAll() throws
}

@MainActor
struct SwiftDataClassAttendancePersistence: ClassAttendanceLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("ClassAttendance", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: ClassAttendanceEntity.self, configurations: config)
    }

    func getAttendance() -> [ClassAttendanceModel] {
        let descriptor = FetchDescriptor<ClassAttendanceEntity>(
            sortBy: [SortDescriptor(\.checkInDate, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: ClassAttendanceModel) throws {
        let entity = ClassAttendanceEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ model: ClassAttendanceModel) throws {
        let idToMatch = model.attendanceId
        let descriptor = FetchDescriptor<ClassAttendanceEntity>(
            predicate: #Predicate { $0.attendanceId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: model)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<ClassAttendanceEntity>(
            predicate: #Predicate { $0.attendanceId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: ClassAttendanceEntity.self)
        try container.mainContext.save()
    }
}
