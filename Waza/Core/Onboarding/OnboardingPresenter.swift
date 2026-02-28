import SwiftUI
import SwiftfulOnboarding

struct OnboardingDelegate {
    var eventParameters: [String: Any]? { nil }
}

@Observable
@MainActor
class OnboardingPresenter {

    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter

    var configuration: OnbConfiguration

    init(interactor: OnboardingInteractor, router: OnboardingRouter) {
        self.interactor = interactor
        self.router = router
        self.configuration = OnboardingPresenter.buildConfiguration()
        // Self is fully initialized — safe to capture weakly in callback
        self.configuration.onFlowComplete = { [weak self] flowData in
            Task { @MainActor in
                self?.handleFlowComplete(flowData: flowData)
            }
        }
    }

    func onViewAppear(delegate: OnboardingDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: OnboardingDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onSkipPressed() {
        interactor.trackEvent(event: Event.onboardingSkipped)
        Task {
            try? await interactor.markOnboardingComplete()
        }
        router.switchToCoreModule()
    }

    // MARK: - Private

    private func handleFlowComplete(flowData: OnbFlowData) {
        interactor.trackEvent(event: Event.onboardingCompleted)

        // Persist belt selection — defaults to white if skipped
        let beltId = flowData.slides.first(where: { $0.slideId == "belt" })?.selections.first?.id ?? "white"
        let belt = BJJBelt(rawValue: beltId) ?? .white
        try? interactor.setInitialBelt(belt: belt, stripes: 0, date: Date(), academy: nil, notes: nil)

        Task {
            try? await interactor.markOnboardingComplete()
        }

        router.switchToCoreModule()
    }

    // MARK: - Configuration builder

    private static func buildConfiguration() -> OnbConfiguration {
        let accentColor = Color.accentColor
        let optionStyle = OnbButtonStyleType.solid(
            backgroundColor: .white.opacity(0.12),
            textColor: .white,
            selectedBackgroundColor: accentColor,
            selectedTextColor: .white
        )
        let ctaStyle = OnbButtonStyleType.solid(
            backgroundColor: accentColor,
            textColor: .white
        )
        return OnbConfiguration(
            headerConfiguration: OnbHeaderConfiguration(
                headerStyle: .progressBar,
                headerAlignment: .center,
                showBackButton: .afterFirstSlide,
                backButtonColor: .white,
                progressBarAccentColor: accentColor
            ),
            slides: [
                trackSlide(ctaStyle: ctaStyle),
                beltSlide(optionStyle: optionStyle),
                readySlide(ctaStyle: ctaStyle)
            ],
            slideDefaults: OnbSlideDefaults(
                titleFont: .title2.weight(.bold),
                subtitleFont: .subheadline,
                contentAlignment: .center,
                ctaText: "Continue",
                ctaButtonStyle: ctaStyle,
                background: .solidColor(.black)
            )
        )
    }

    private static func trackSlide(ctaStyle: OnbButtonStyleType) -> OnbSlideType {
        .regular(
            id: "track",
            title: "Your BJJ journal.",
            subtitle: "Log sessions, track submissions, and discover the gaps in your game.",
            media: .systemIcon(named: "figure.martial.arts"),
            ctaButtonStyle: ctaStyle,
            showBackButton: false
        )
    }

    private static func beltSlide(optionStyle: OnbButtonStyleType) -> OnbSlideType {
        .multipleChoice(
            id: "belt",
            title: "What's your current belt?",
            subtitle: "You can update this anytime in your profile.",
            options: [
                OnbChoiceOption(id: "white", content: OnbButtonContentData(text: "White")),
                OnbChoiceOption(id: "blue", content: OnbButtonContentData(text: "Blue")),
                OnbChoiceOption(id: "purple", content: OnbButtonContentData(text: "Purple")),
                OnbChoiceOption(id: "brown", content: OnbButtonContentData(text: "Brown")),
                OnbChoiceOption(id: "black", content: OnbButtonContentData(text: "Black"))
            ],
            optionsButtonStyle: optionStyle,
            selectionBehavior: .single(autoAdvance: true),
            isGrid: true
        )
    }

    private static func readySlide(ctaStyle: OnbButtonStyleType) -> OnbSlideType {
        .regular(
            id: "ready",
            title: "You're all set.",
            subtitle: "Start logging sessions and watch your game evolve.",
            media: .systemIcon(named: "checkmark.seal.fill"),
            ctaText: "Let's Train",
            ctaButtonStyle: ctaStyle
        )
    }
}

// MARK: - Events

extension OnboardingPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: OnboardingDelegate)
        case onDisappear(delegate: OnboardingDelegate)
        case onboardingCompleted
        case onboardingSkipped

        var eventName: String {
            switch self {
            case .onAppear:             return "OnboardingView_Appear"
            case .onDisappear:          return "OnboardingView_Disappear"
            case .onboardingCompleted:  return "OnboardingView_Completed"
            case .onboardingSkipped:    return "OnboardingView_Skipped"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
