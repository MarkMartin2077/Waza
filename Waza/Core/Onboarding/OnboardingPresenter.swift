import SwiftUI

struct OnboardingDelegate {
    var eventParameters: [String: Any]? { nil }
}

@Observable
@MainActor
class OnboardingPresenter {

    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter

    static let totalPages = 6

    var currentPage: Int = 0
    var enteredName: String = ""
    var selectedGoalId: String?
    var isCompletingOnboarding: Bool = false

    var isLastPage: Bool {
        currentPage >= Self.totalPages - 1
    }

    init(interactor: any OnboardingInteractor, router: any OnboardingRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: OnboardingDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: OnboardingDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onPageChanged(_ page: Int) {
        interactor.trackEvent(event: Event.pageChanged(page: page))
    }

    func onSkipPressed() {
        interactor.trackEvent(event: Event.onboardingSkipped)
        Task {
            try? await interactor.markOnboardingComplete()
        }
        router.switchToCoreModule()
    }

    func onContinuePressed() {
        interactor.trackEvent(event: Event.continuePressed(fromPage: currentPage))
        advance()
    }

    func onGoalSelected(_ goalId: String) {
        interactor.trackEvent(event: Event.goalSelected(goalId: goalId))
        selectedGoalId = goalId
        advance()
    }

    func onEnableNotificationsTapped() {
        interactor.trackEvent(event: Event.notificationsEnablePressed)
        Task {
            _ = try? await interactor.requestPushAuthorization()
            advance()
        }
    }

    func onSkipNotificationsTapped() {
        interactor.trackEvent(event: Event.notificationsSkipped)
        advance()
    }

    func onEnableLocationTapped() {
        interactor.trackEvent(event: Event.locationEnablePressed)
        interactor.requestLocationAuthorization()
        advance()
    }

    func onSkipLocationTapped() {
        interactor.trackEvent(event: Event.locationSkipped)
        advance()
    }

    func onFinishPressed() {
        isCompletingOnboarding = true
        interactor.trackEvent(event: Event.finishStart)

        Task {
            do {
                let trimmedName = enteredName.trimmingCharacters(in: .whitespaces)
                if !trimmedName.isEmpty {
                    try await interactor.saveUserName(name: trimmedName)
                }

                if let goalId = selectedGoalId, let goal = Int(goalId) {
                    try await interactor.saveTrainingGoal(sessionsPerWeek: goal)
                }

                try await interactor.markOnboardingComplete()
                interactor.trackEvent(event: Event.finishSuccess)
                router.switchToCoreModule()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }

            isCompletingOnboarding = false
        }
    }

    private func advance() {
        guard !isLastPage else { return }
        currentPage += 1
    }
}

// MARK: - Events

extension OnboardingPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: OnboardingDelegate)
        case onDisappear(delegate: OnboardingDelegate)
        case pageChanged(page: Int)
        case continuePressed(fromPage: Int)
        case onboardingSkipped
        case goalSelected(goalId: String)
        case notificationsEnablePressed
        case notificationsSkipped
        case locationEnablePressed
        case locationSkipped
        case finishStart
        case finishSuccess
        case finishFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                    return "OnboardingView_Appear"
            case .onDisappear:                 return "OnboardingView_Disappear"
            case .pageChanged:                 return "OnboardingView_Page_Changed"
            case .continuePressed:             return "OnboardingView_Continue_Pressed"
            case .onboardingSkipped:           return "OnboardingView_Skipped"
            case .goalSelected:                return "OnboardingView_Goal_Selected"
            case .notificationsEnablePressed:  return "OnboardingView_Notifications_Enable"
            case .notificationsSkipped:        return "OnboardingView_Notifications_Skip"
            case .locationEnablePressed:       return "OnboardingView_Location_Enable"
            case .locationSkipped:             return "OnboardingView_Location_Skip"
            case .finishStart:                 return "OnboardingView_Finish_Start"
            case .finishSuccess:               return "OnboardingView_Finish_Success"
            case .finishFail:                  return "OnboardingView_Finish_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .pageChanged(page: let page):
                return ["page": page]
            case .continuePressed(fromPage: let page):
                return ["from_page": page]
            case .goalSelected(goalId: let goalId):
                return ["goal_id": goalId]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
