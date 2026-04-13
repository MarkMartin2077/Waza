import SwiftUI

@MainActor
protocol MonthlyReportInteractor: GlobalInteractor {
    var currentUserName: String { get }
    func getMonthlyReportData(for dateRange: DateRange) async -> MonthlyReportData
}

extension CoreInteractor: MonthlyReportInteractor { }
