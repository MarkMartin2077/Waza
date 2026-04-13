import SwiftUI

@Observable
@MainActor
class GoalsPlanningPresenter {
    private let interactor: GoalsPlanningInteractor
    private let router: GoalsPlanningRouter
    let delegate: GoalsPlanningDelegate

    private(set) var activeGoals: [TrainingGoalModel] = []
    private(set) var completedGoals: [TrainingGoalModel] = []

    var showCompletedGoals: Bool = false

    init(interactor: GoalsPlanningInteractor, router: GoalsPlanningRouter, delegate: GoalsPlanningDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
    }

    func loadData() {
        activeGoals = interactor.activeGoals
        completedGoals = interactor.completedGoals
    }

    func onAddGoalTapped() {
        interactor.trackEvent(event: Event.addGoalTapped)
        router.showAddGoalSheet(
            focusAreaOptions: interactor.distinctFocusAreas,
            onSave: { [weak self] metric, target, focusArea in
                self?.saveNewGoal(metric: metric, target: target, focusArea: focusArea)
            }
        )
    }

    private func saveNewGoal(metric: GoalMetric, target: Int, focusArea: String?) {
        interactor.trackEvent(event: Event.saveGoalTapped)

        do {
            _ = try interactor.createMetricGoal(
                metric: metric,
                targetValue: Double(target),
                focusArea: focusArea
            )
            router.dismissScreen()
            loadData()
            interactor.playHaptic(option: .success)
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }

    func onUpdateProgress(_ goal: TrainingGoalModel, newProgress: Double) {
        guard !goal.isMetricGoal else { return }
        interactor.trackEvent(event: Event.updateProgressTapped)
        do {
            try interactor.updateGoalProgress(goalId: goal.id, progress: newProgress)
            loadData()
            interactor.trackEvent(event: Event.updateProgressSuccess)
        } catch {
            interactor.trackEvent(event: Event.updateProgressFail(error: error))
            router.showAlert(error: error)
        }
    }

    func onCompleteGoal(_ goal: TrainingGoalModel) {
        guard !goal.isMetricGoal else { return }
        interactor.trackEvent(event: Event.goalCompleted)
        do {
            try interactor.completeGoal(goalId: goal.id)
            loadData()
            interactor.playHaptic(option: .success)
        } catch {
            interactor.trackEvent(event: Event.completeGoalFail(error: error))
            router.showAlert(error: error)
        }
    }

    func onDeleteGoal(_ goal: TrainingGoalModel) {
        interactor.trackEvent(event: Event.goalDeleted)
        do {
            try interactor.deleteGoal(goal)
            loadData()
        } catch {
            interactor.trackEvent(event: Event.deleteGoalFail(error: error))
            router.showAlert(error: error)
        }
    }

    // MARK: - Progress Helpers

    func computedProgress(for goal: TrainingGoalModel) -> Double {
        goal.isMetricGoal ? interactor.computeProgress(for: goal) : goal.progress
    }

    func progressLabel(for goal: TrainingGoalModel) -> String? {
        guard let metric = goal.goalMetric, let target = goal.targetValue else { return nil }
        let current = interactor.currentValue(for: goal)
        switch metric {
        case .sessionsPerWeek:
            return "\(Int(current))/\(Int(target)) this week"
        case .sessionsPerMonth:
            return "\(Int(current))/\(Int(target)) this month"
        case .hoursPerMonth:
            return String(format: "%.1f/%.0f hours this month", current, target)
        case .focusAreaSessions:
            return "\(Int(current))/\(Int(target)) sessions"
        }
    }

}

extension GoalsPlanningPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case addGoalTapped
        case cancelAddGoalTapped
        case saveGoalTapped
        case goalCompleted
        case goalDeleted
        case updateProgressTapped
        case updateProgressSuccess
        case saveFail(error: Error)
        case updateProgressFail(error: Error)
        case completeGoalFail(error: Error)
        case deleteGoalFail(error: Error)
        case formInteraction

        var eventName: String {
            switch self {
            case .onAppear:             return "GoalsPlanningView_Appear"
            case .addGoalTapped:        return "GoalsPlanningView_AddGoal_Tap"
            case .cancelAddGoalTapped:  return "GoalsPlanningView_CancelAddGoal_Tap"
            case .saveGoalTapped:       return "GoalsPlanningView_SaveGoal_Tap"
            case .goalCompleted:        return "GoalsPlanningView_Goal_Complete"
            case .goalDeleted:          return "GoalsPlanningView_Goal_Delete"
            case .updateProgressTapped: return "GoalsPlanningView_UpdateProgress_Tap"
            case .updateProgressSuccess: return "GoalsPlanningView_UpdateProgress_Success"
            case .saveFail:             return "GoalsPlanningView_Save_Fail"
            case .updateProgressFail:   return "GoalsPlanningView_UpdateProgress_Fail"
            case .completeGoalFail:     return "GoalsPlanningView_CompleteGoal_Fail"
            case .deleteGoalFail:       return "GoalsPlanningView_DeleteGoal_Fail"
            case .formInteraction:      return "GoalsPlanningView_Form_Interaction"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .saveFail(error: let error),
                 .updateProgressFail(error: let error),
                 .completeGoalFail(error: let error),
                 .deleteGoalFail(error: let error):
                return error.eventParameters
            default: return nil
            }
        }

        var type: LogType {
            switch self {
            case .saveFail, .updateProgressFail, .completeGoalFail, .deleteGoalFail:
                return .severe
            default: return .analytic
            }
        }
    }
}

struct GoalsPlanningDelegate {
    var eventParameters: [String: Any]? { nil }
}
