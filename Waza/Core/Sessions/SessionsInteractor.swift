import SwiftUI

@MainActor
protocol SessionsInteractor: GlobalInteractor {
    var currentBeltEnum: BJJBelt { get }
    var allSessions: [BJJSessionModel] { get }
    var sessionStats: SessionStats { get }
    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? { get }
    var gyms: [GymLocationModel] { get }
    var schedules: [ClassScheduleModel] { get }
    var currentStreakData: CurrentStreakData { get }
    func deleteSession(_ session: BJJSessionModel) throws
    func updateWidgetData(_ data: WazaWidgetData)
}

extension CoreInteractor: SessionsInteractor { }
