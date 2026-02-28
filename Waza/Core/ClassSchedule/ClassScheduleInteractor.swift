import SwiftUI

struct AddScheduleParams {
    var gymId: String
    var name: String
    var dayOfWeek: Int
    var startHour: Int
    var startMinute: Int
    var durationMinutes: Int = 60
    var sessionType: SessionType = .gi
    var reminderMinutesBefore: Int = 30
}

@MainActor
protocol ClassScheduleInteractor: GlobalInteractor {
    var gyms: [GymLocationModel] { get }
    var schedules: [ClassScheduleModel] { get }
    @discardableResult
    func addGym(name: String, address: String?, latitude: Double, longitude: Double, radius: Double) throws -> GymLocationModel
    func updateGym(_ gym: GymLocationModel) throws
    func deleteGym(_ gym: GymLocationModel) throws
    @discardableResult
    func addSchedule(_ params: AddScheduleParams) throws -> ClassScheduleModel
    func updateSchedule(_ schedule: ClassScheduleModel) throws
    func deleteSchedule(_ schedule: ClassScheduleModel) throws
}

extension CoreInteractor: ClassScheduleInteractor { }
