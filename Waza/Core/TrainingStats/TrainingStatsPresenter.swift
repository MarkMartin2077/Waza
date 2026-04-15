import SwiftUI

@Observable
@MainActor
class TrainingStatsPresenter {
    let router: any TrainingStatsRouter
    let interactor: any TrainingStatsInteractor

    /// Blocks rapid double-taps on toolbar buttons from pushing duplicate screens.
    private let navGuard = NavigationGuard()

    var selectedPeriodLabel: String = "Month"

    let periodLabels = ["Week", "Month", "Year", "All Time"]

    var snapshot: TrainingSnapshot {
        interactor.getTrainingSnapshot(period: currentPeriod)
    }

    var activeGoals: [TrainingGoalModel] {
        interactor.activeGoals
    }

    private var currentPeriod: DateRange {
        switch selectedPeriodLabel {
        case "Week":     return .lastWeek
        case "Year":     return .lastYear
        case "All Time": return .allTime
        default:         return .lastMonth
        }
    }

    init(router: any TrainingStatsRouter, interactor: any TrainingStatsInteractor) {
        self.router = router
        self.interactor = interactor
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onManageGoalsTapped() {
        navGuard.perform {
            interactor.trackEvent(event: Event.manageGoalsTapped)
            router.showGoalsPlanningView()
        }
    }

    func onAIInsightsTapped() {
        navGuard.perform {
            interactor.trackEvent(event: Event.aiInsightsTapped)
            router.showAIInsightsView()
        }
    }

    var isAIAvailable: Bool {
        interactor.isAIAvailable
    }

    func onPeriodSelected(label: String) {
        interactor.trackEvent(event: Event.periodChanged(label: label))
        selectedPeriodLabel = label
    }

    func computedProgress(for goal: TrainingGoalModel) -> Double {
        goal.isMetricGoal ? interactor.computeProgress(for: goal) : goal.progress
    }
}

extension TrainingStatsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case periodChanged(label: String)
        case manageGoalsTapped
        case aiInsightsTapped

        var eventName: String {
            switch self {
            case .onAppear:          return "TrainingStats_Appear"
            case .periodChanged:     return "TrainingStats_PeriodChange"
            case .manageGoalsTapped: return "TrainingStats_ManageGoals_Tap"
            case .aiInsightsTapped:  return "TrainingStats_AIInsights_Tap"
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
