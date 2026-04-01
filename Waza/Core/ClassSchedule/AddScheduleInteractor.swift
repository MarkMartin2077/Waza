import SwiftUI

@MainActor
protocol AddScheduleInteractor: GlobalInteractor {
    @discardableResult
    func addSchedule(_ params: AddScheduleParams) throws -> ClassScheduleModel
    func updateSchedule(_ schedule: ClassScheduleModel) throws
    @discardableResult
    func requestPushAuthorization() async throws -> Bool
}

extension CoreInteractor: AddScheduleInteractor { }
