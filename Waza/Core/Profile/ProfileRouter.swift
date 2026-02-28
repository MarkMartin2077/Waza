import SwiftUI

@MainActor
protocol ProfileRouter: GlobalRouter {
    func showSettingsView()
    func showClassScheduleView()
}

extension CoreRouter: ProfileRouter { }
