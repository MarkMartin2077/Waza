import SwiftUI

@Observable
@MainActor
class MonthlyReportPresenter {
    let interactor: any MonthlyReportInteractor
    let router: any MonthlyReportRouter

    private(set) var reportData: MonthlyReportData?
    private(set) var shareCardImage: UIImage?
    private(set) var isLoading: Bool = true

    /// How many months back from current (1 = last month, 2 = two months ago, etc.)
    var selectedMonthsAgo: Int = 1 {
        didSet {
            guard selectedMonthsAgo != oldValue else { return }
            interactor.trackEvent(event: Event.monthChanged(monthsAgo: selectedMonthsAgo))
            loadReport()
        }
    }

    /// Month labels for the picker (last 6 months).
    let monthOptions: [(label: String, monthsAgo: Int)] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let calendar = Calendar.current
        let now = Date()
        return (1...6).compactMap { offset in
            guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
                  let target = calendar.date(byAdding: .month, value: -offset, to: monthStart) else { return nil }
            return (label: formatter.string(from: target), monthsAgo: offset)
        }
    }()

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
        isLoading = true
        shareCardImage = nil
        Task { @MainActor in
            let range = DateRange.calendarMonth(monthsAgo: selectedMonthsAgo)
            let data = await interactor.getMonthlyReportData(for: range)
            reportData = data.totalSessions > 0 ? data : nil
            isLoading = false
        }
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
        case monthChanged(monthsAgo: Int)

        var eventName: String {
            switch self {
            case .onAppear:     return "MonthlyReport_Appear"
            case .shareTapped:  return "MonthlyReport_Share_Tap"
            case .monthChanged: return "MonthlyReport_Month_Change"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .monthChanged(monthsAgo: let months):
                return ["months_ago": months]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
