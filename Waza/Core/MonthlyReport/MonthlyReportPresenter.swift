import SwiftUI

@Observable
@MainActor
class MonthlyReportPresenter {
    let interactor: any MonthlyReportInteractor
    let router: any MonthlyReportRouter

    private(set) var reportData: MonthlyReportData?
    private(set) var shareCardImage: UIImage?

    init(interactor: any MonthlyReportInteractor, router: any MonthlyReportRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadReport()
    }

    func onShareTapped() {
        interactor.trackEvent(event: Event.shareTapped)
        generateShareImage()
    }

    // MARK: - Private

    private func loadReport() {
        let range = DateRange.previousCalendarMonth
        reportData = interactor.getMonthlyReportData(for: range)
    }

    private func generateShareImage() {
        guard let data = reportData else { return }
        shareCardImage = ShareCardRenderer.render(
            card: ShareCardView(
                cardType: .monthlyReport(
                    month: data.monthLabel,
                    sessions: data.totalSessions,
                    hours: data.totalHoursFormatted,
                    streakDays: data.longestStreakInMonth,
                    level: data.levelInfo.level,
                    title: data.levelInfo.title
                ),
                userName: interactor.currentUserName,
                accentColor: .wazaAccent
            )
        )
    }
}

// MARK: - Events

extension MonthlyReportPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case shareTapped

        var eventName: String {
            switch self {
            case .onAppear:   return "MonthlyReport_Appear"
            case .shareTapped: return "MonthlyReport_Share_Tap"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
