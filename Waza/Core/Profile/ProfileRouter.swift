import SwiftUI

@MainActor
protocol ProfileRouter: GlobalRouter {
    func showSettingsView()
    func showClassScheduleView()
    func showAchievementsView()
    func showMonthlyReportView()
}

extension CoreRouter: ProfileRouter {

    func showAchievementsView() {
        router.showScreen(.push) { router in
            self.builder.achievementsView(router: router)
        }
    }

}
