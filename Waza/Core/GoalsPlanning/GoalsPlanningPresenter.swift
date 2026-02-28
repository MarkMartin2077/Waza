import SwiftUI

@Observable
@MainActor
class GoalsPlanningPresenter {
    private let interactor: GoalsPlanningInteractor
    private let router: GoalsPlanningRouter
    let delegate: GoalsPlanningDelegate

    private(set) var activeGoals: [TrainingGoalModel] = []
    private(set) var completedGoals: [TrainingGoalModel] = []
    private(set) var currentBelt: BJJBelt = .white

    var showAddGoalSheet: Bool = false
    var showCompletedGoals: Bool = false
    var errorMessage: String?

    // New goal form
    var newGoalTitle: String = ""
    var newGoalDescription: String = ""
    var newGoalType: GoalType = .custom
    var newGoalDeadline: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    var newGoalHasDeadline: Bool = false

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
        currentBelt = interactor.currentBeltEnum
    }

    func onAddGoalTapped() {
        interactor.trackEvent(event: Event.addGoalTapped)
        resetNewGoalForm()
        showAddGoalSheet = true
    }

    func onSaveNewGoal() {
        interactor.trackEvent(event: Event.saveGoalTapped)
        guard !newGoalTitle.isEmpty else { return }

        do {
            _ = try interactor.createGoal(
                title: newGoalTitle,
                description: newGoalDescription.isEmpty ? nil : newGoalDescription,
                goalType: newGoalType,
                deadline: newGoalHasDeadline ? newGoalDeadline : nil
            )
            showAddGoalSheet = false
            loadData()
            interactor.playHaptic(option: .success)
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    func onCancelAddGoal() {
        interactor.trackEvent(event: Event.cancelAddGoalTapped)
        showAddGoalSheet = false
    }

    func onUpdateProgress(_ goal: TrainingGoalModel, newProgress: Double) {
        do {
            try interactor.updateGoalProgress(goalId: goal.id, progress: newProgress)
            loadData()
        } catch {
            interactor.trackEvent(event: Event.updateProgressFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    func onCompleteGoal(_ goal: TrainingGoalModel) {
        interactor.trackEvent(event: Event.goalCompleted)
        do {
            try interactor.completeGoal(goalId: goal.id)
            loadData()
            interactor.playHaptic(option: .success)
        } catch {
            interactor.trackEvent(event: Event.completeGoalFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    func onDeleteGoal(_ goal: TrainingGoalModel) {
        interactor.trackEvent(event: Event.goalDeleted)
        do {
            try interactor.deleteGoal(goal)
            loadData()
        } catch {
            interactor.trackEvent(event: Event.deleteGoalFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    private func resetNewGoalForm() {
        newGoalTitle = ""
        newGoalDescription = ""
        newGoalType = .custom
        newGoalDeadline = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        newGoalHasDeadline = false
    }

    var nextBeltText: String {
        guard let next = currentBelt.nextBelt else { return "You've reached black belt!" }
        return "Working towards \(next.displayName) belt"
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
        case saveFail(error: Error)
        case updateProgressFail(error: Error)
        case completeGoalFail(error: Error)
        case deleteGoalFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "GoalsPlanningView_Appear"
            case .addGoalTapped:        return "GoalsPlanningView_AddGoal_Tap"
            case .cancelAddGoalTapped:  return "GoalsPlanningView_CancelAddGoal_Tap"
            case .saveGoalTapped:       return "GoalsPlanningView_SaveGoal_Tap"
            case .goalCompleted:        return "GoalsPlanningView_Goal_Complete"
            case .goalDeleted:          return "GoalsPlanningView_Goal_Delete"
            case .saveFail:             return "GoalsPlanningView_Save_Fail"
            case .updateProgressFail:   return "GoalsPlanningView_UpdateProgress_Fail"
            case .completeGoalFail:     return "GoalsPlanningView_CompleteGoal_Fail"
            case .deleteGoalFail:       return "GoalsPlanningView_DeleteGoal_Fail"
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
