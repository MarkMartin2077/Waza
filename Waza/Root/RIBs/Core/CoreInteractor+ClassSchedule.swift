import SwiftUI

extension CoreInteractor {

    // MARK: Class Schedule

    var gyms: [GymLocationModel] {
        classScheduleManager.gyms
    }

    var schedules: [ClassScheduleModel] {
        classScheduleManager.schedules
    }

    var classAttendance: [ClassAttendanceModel] {
        classScheduleManager.attendance
    }

    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? {
        classScheduleManager.nextUpcomingClass
    }

    func weeklyAttendanceCount(weekOf date: Date = Date()) -> Int {
        classScheduleManager.weeklyAttendanceCount(weekOf: date)
    }

    @discardableResult
    func addGym(name: String, address: String? = nil, latitude: Double, longitude: Double, radius: Double = 150) throws -> GymLocationModel {
        try classScheduleManager.addGym(name: name, address: address, latitude: latitude, longitude: longitude, radius: radius)
    }

    func updateGym(_ gym: GymLocationModel) throws {
        try classScheduleManager.updateGym(gym)
    }

    func deleteGym(_ gym: GymLocationModel) throws {
        try classScheduleManager.deleteGym(gym)
    }

    @discardableResult
    func addSchedule(_ params: AddScheduleParams) throws -> ClassScheduleModel {
        try classScheduleManager.addSchedule(params)
    }

    func updateSchedule(_ schedule: ClassScheduleModel) throws {
        try classScheduleManager.updateSchedule(schedule)
    }

    func deleteSchedule(_ schedule: ClassScheduleModel) throws {
        try classScheduleManager.deleteSchedule(schedule)
    }

    @discardableResult
    func checkIn(gymId: String, scheduleId: String? = nil, method: CheckInMethod = .manual, moodRating: Int? = nil) throws -> ClassAttendanceModel {
        let record = try classScheduleManager.checkIn(gymId: gymId, scheduleId: scheduleId, method: method, moodRating: moodRating)
        let totalCount = classScheduleManager.attendance.count
        let thisWeek = classScheduleManager.weeklyAttendanceCount()
        let weeklyTarget = 3
        let isPerfectWeek = thisWeek >= weeklyTarget
        achievementManager.checkAndAward(
            event: .classCheckedIn(totalCount: totalCount, isPerfectWeek: isPerfectWeek, consecutivePerfectWeeks: 0),
            sessionStats: sessionStats,
            streakCount: currentStreakData.currentStreak ?? 0
        )
        return record
    }

    func updateAttendance(_ record: ClassAttendanceModel) throws {
        try classScheduleManager.updateAttendance(record)
    }

    func generateCheckInEncouragement(
        streakCount: Int,
        classesThisWeek: Int,
        weeklyTarget: Int,
        belt: BJJBelt,
        totalAttendance: Int
    ) -> AsyncThrowingStream<String, Error> {
        aiInsightsManager.generateCheckInEncouragement(
            streakCount: streakCount,
            classesThisWeek: classesThisWeek,
            weeklyTarget: weeklyTarget,
            belt: belt,
            totalAttendance: totalAttendance
        )
    }

}
