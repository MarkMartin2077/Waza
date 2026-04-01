import Foundation

@Observable
@MainActor
class ClassScheduleManager: GeofenceCoordinatorDelegate {
    private let gymService: GymLocationLocalService
    private let scheduleService: ClassScheduleLocalService
    private let attendanceService: ClassAttendanceLocalService
    private let geofenceCoordinator = GeofenceCoordinator()
    private let notificationScheduler = ClassNotificationScheduler()

    private(set) var gyms: [GymLocationModel] = []
    private(set) var schedules: [ClassScheduleModel] = []
    private(set) var attendance: [ClassAttendanceModel] = []

    init(services: ClassScheduleServices) {
        self.gymService = services.gymLocation
        self.scheduleService = services.schedule
        self.attendanceService = services.attendance
        geofenceCoordinator.delegate = self
        refresh()
    }

    func refresh() {
        gyms = gymService.getGyms()
        schedules = scheduleService.getSchedules()
        attendance = attendanceService.getAttendance()
    }

    // MARK: - Gym CRUD

    @discardableResult
    func addGym(
        name: String,
        address: String? = nil,
        latitude: Double,
        longitude: Double,
        radius: Double = 150
    ) throws -> GymLocationModel {
        let model = GymLocationModel(
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            geofenceRadius: radius
        )
        try gymService.create(model)
        refresh()
        geofenceCoordinator.startMonitoring(gyms: [model])
        return model
    }

    func updateGym(_ model: GymLocationModel) throws {
        try gymService.update(model)
        geofenceCoordinator.stopMonitoring(gymId: model.gymId)
        if model.isActive {
            geofenceCoordinator.startMonitoring(gyms: [model])
        }
        refresh()
    }

    func deleteGym(_ model: GymLocationModel) throws {
        geofenceCoordinator.stopMonitoring(gymId: model.gymId)
        let gymSchedules = schedules.filter { $0.gymId == model.gymId }
        for schedule in gymSchedules {
            notificationScheduler.cancelReminder(scheduleId: schedule.scheduleId)
            try scheduleService.delete(id: schedule.scheduleId)
        }
        try gymService.delete(id: model.gymId)
        refresh()
    }

    // MARK: - Schedule CRUD

    @discardableResult
    func addSchedule(_ params: AddScheduleParams) throws -> ClassScheduleModel {
        let model = ClassScheduleModel(
            gymId: params.gymId,
            name: params.name,
            dayOfWeek: params.dayOfWeek,
            startHour: params.startHour,
            startMinute: params.startMinute,
            durationMinutes: params.durationMinutes,
            sessionType: params.sessionType,
            reminderMinutesBefore: params.reminderMinutesBefore
        )
        try scheduleService.create(model)
        if let gym = gyms.first(where: { $0.gymId == params.gymId }) {
            notificationScheduler.scheduleReminder(for: model, gym: gym)
        }
        refresh()
        return model
    }

    func updateSchedule(_ model: ClassScheduleModel) throws {
        notificationScheduler.cancelReminder(scheduleId: model.scheduleId)
        try scheduleService.update(model)
        if model.isActive, let gym = gyms.first(where: { $0.gymId == model.gymId }) {
            notificationScheduler.scheduleReminder(for: model, gym: gym)
        }
        refresh()
    }

    func deleteSchedule(_ model: ClassScheduleModel) throws {
        notificationScheduler.cancelReminder(scheduleId: model.scheduleId)
        try scheduleService.delete(id: model.scheduleId)
        refresh()
    }

    // MARK: - Attendance CRUD

    @discardableResult
    func checkIn(
        gymId: String,
        scheduleId: String? = nil,
        method: CheckInMethod = .manual,
        moodRating: Int? = nil
    ) throws -> ClassAttendanceModel {
        let model = ClassAttendanceModel(
            gymId: gymId,
            scheduleId: scheduleId,
            checkInMethod: method,
            moodRating: moodRating
        )
        try attendanceService.create(model)
        refresh()
        return model
    }

    func updateAttendance(_ model: ClassAttendanceModel) throws {
        try attendanceService.update(model)
        refresh()
    }

    // MARK: - Computed

    /// The next upcoming scheduled class, paired with its gym.
    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? {
        let active = schedules.filter { $0.isActive }
        guard let soonest = active.min(by: { $0.nextOccurrence < $1.nextOccurrence }) else { return nil }
        guard let gym = gyms.first(where: { $0.gymId == soonest.gymId }) else { return nil }
        return (soonest, gym)
    }

    /// The closest schedule to the given time for a specific gym on the same weekday.
    func closestSchedule(forGymId gymId: String, at date: Date = Date()) -> ClassScheduleModel? {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: date)
        let nowMinutes = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)

        let candidates = schedules.filter {
            $0.gymId == gymId && $0.isActive && $0.dayOfWeek == todayWeekday
        }

        return candidates.min(by: {
            abs(($0.startHour * 60 + $0.startMinute) - nowMinutes) < abs(($1.startHour * 60 + $1.startMinute) - nowMinutes)
        })
    }

    /// Number of check-ins during the calendar week containing the given date.
    func weeklyAttendanceCount(weekOf date: Date = Date()) -> Int {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        return attendance.filter { weekInterval.contains($0.checkInDate) }.count
    }

    /// Count how many consecutive calendar weeks (ending with the current week)
    /// the user met their weekly attendance target.
    func consecutivePerfectWeeks(weeklyTarget: Int) -> Int {
        guard weeklyTarget > 0 else { return 0 }
        let calendar = Calendar.current
        var count = 0
        var weekDate = Date()

        while true {
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekDate) else { break }
            let weekCount = attendance.filter { weekInterval.contains($0.checkInDate) }.count
            if weekCount >= weeklyTarget {
                count += 1
            } else {
                break
            }
            // Move to the previous week
            guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: weekInterval.start) else { break }
            weekDate = previousWeek
        }

        return count
    }

    // MARK: - Lifecycle

    func startGeofencing() {
        geofenceCoordinator.requestAlwaysAuthorization()
        geofenceCoordinator.startMonitoring(gyms: gyms)
    }

    func clearAll() {
        geofenceCoordinator.stopAllMonitoring()
        notificationScheduler.cancelAllReminders()
        try? gymService.deleteAll()
        try? scheduleService.deleteAll()
        try? attendanceService.deleteAll()
        gyms = []
        schedules = []
        attendance = []
    }

    func seedMockDataIfEmpty() {
        guard gyms.isEmpty else { return }
        for gym in GymLocationModel.mocks {
            try? gymService.create(gym)
        }
        for schedule in ClassScheduleModel.mocks {
            try? scheduleService.create(schedule)
        }
        for record in ClassAttendanceModel.mocks {
            try? attendanceService.create(record)
        }
        refresh()
    }

    // MARK: - GeofenceCoordinatorDelegate

    func didEnterGym(_ gym: GymLocationModel) {
        notificationScheduler.scheduleGeofenceArrivalNotification(gym: gym)
        NotificationCenter.default.post(
            name: .gymArrival,
            object: nil,
            userInfo: ["gymId": gym.gymId]
        )
    }
}
