import SwiftUI

@MainActor
protocol MonthlyReportInteractor: GlobalInteractor {
    var currentUserName: String { get }
    func getMonthlyReportData(for dateRange: DateRange) -> MonthlyReportData
}

extension CoreInteractor: MonthlyReportInteractor { }
