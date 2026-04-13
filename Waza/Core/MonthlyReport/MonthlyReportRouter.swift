import SwiftUI

@MainActor
protocol MonthlyReportRouter: GlobalRouter { }

extension CoreRouter: MonthlyReportRouter { }
