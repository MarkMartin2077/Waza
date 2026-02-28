import SwiftUI

@Observable
@MainActor
class TrainingStatsPresenter {
    let router: any TrainingStatsRouter
    let interactor: any TrainingStatsInteractor

    var selectedPeriod: DateRange = .lastMonth
    var selectedPeriodLabel: String = "Month"

    var snapshot: TrainingSnapshot = .empty
    var claStats: CLAStatSummary = CLAStatSummary(
        totalTimePracticed: 0,
        uniqueGamesPlayed: 0,
        totalDiscoveries: 0,
        mostPlayedGame: nil
    )

    let periodOptions: [(label: String, range: DateRange)] = [
        ("Week", .lastWeek),
        ("Month", .lastMonth),
        ("Year", .lastYear),
        ("All Time", .allTime)
    ]

    init(router: any TrainingStatsRouter, interactor: any TrainingStatsInteractor) {
        self.router = router
        self.interactor = interactor
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadStats()
    }

    func onPeriodSelected(label: String, range: DateRange) {
        interactor.trackEvent(event: Event.periodChanged(label: label))
        selectedPeriodLabel = label
        selectedPeriod = range
        loadStats()
    }

    private func loadStats() {
        snapshot = interactor.getTrainingSnapshot(period: selectedPeriod)
        claStats = interactor.getCLAStatSummary()
    }
}

extension TrainingStatsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case periodChanged(label: String)

        var eventName: String {
            switch self {
            case .onAppear: return "TrainingStats_Appear"
            case .periodChanged: return "TrainingStats_PeriodChange"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .periodChanged(label: let label):
                return ["period": label]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
