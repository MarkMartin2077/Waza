import SwiftUI

@MainActor
protocol AddScheduleRouter: GlobalRouter {
    // Dismissal is provided by GlobalRouter
}

extension CoreRouter: AddScheduleRouter { }
