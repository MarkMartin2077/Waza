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

    init(interactor: any OnboardingInteractor, router: any OnboardingRouter) {
        self.interactor = interactor
        self.router = router
        self.configuration = OnboardingPresenter.buildConfiguration(interactor: interactor)
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

    private static func buildConfiguration(interactor: any OnboardingInteractor) -> OnbConfiguration {
        let accent = Color.accentColor
        let ctaStyle = makeCTAStyle(accent: accent)
        let beltOptionStyle = makeBeltOptionStyle(accent: accent)
        let skipStyle = makeSkipStyle()
        return OnbConfiguration(
            headerConfiguration: OnbHeaderConfiguration(
                headerStyle: .progressBar,
                headerAlignment: .center,
                showBackButton: .afterFirstSlide,
                backButtonColor: .white,
                progressBarAccentColor: accent
            ),
            slides: [
                trackSlide(ctaStyle: ctaStyle, background: makeWarmGradient()),
                beltSlide(optionStyle: beltOptionStyle, background: makeNavyGradient()),
                notificationsSlide(interactor: interactor, ctaStyle: ctaStyle, skipStyle: skipStyle, background: makePurpleGradient()),
                locationSlide(interactor: interactor, ctaStyle: ctaStyle, skipStyle: skipStyle, background: makeTealGradient()),
                readySlide(ctaStyle: ctaStyle, background: makeWarmGradient())
            ],
            slideDefaults: OnbSlideDefaults(
                titleFont: .title2.weight(.bold),
                subtitleFont: .subheadline,
                contentAlignment: .center,
                contentSpacing: 36,
                ctaText: "Continue",
                ctaButtonStyle: ctaStyle,
                ctaButtonFormatData: makeCTAFormat(),
                optionsButtonFormatData: makeOptionFormat(),
                secondaryButtonFormatData: makeSkipFormat(),
                background: .solidColor(Color(white: 0.05)),
                transitionStyle: .fade
            )
        )
    }

    // MARK: - Style factories

    private static func makeCTAStyle(accent: Color) -> OnbButtonStyleType {
        .duolingo(backgroundColor: accent, textColor: .white, shadowColor: accent.opacity(0.5))
    }

    private static func makeCTAFormat() -> OnbButtonFormatData {
        OnbButtonFormatData(pressStyle: .press, font: .subheadline.weight(.semibold), height: .fixed(48), cornerRadius: 14)
    }

    private static func makeBeltOptionStyle(accent: Color) -> OnbButtonStyleType {
        .solidOutline(
            backgroundColor: .white.opacity(0.07),
            textColor: .white,
            borderColor: .white.opacity(0.15),
            selectedBackgroundColor: accent.opacity(0.2),
            selectedTextColor: .white,
            selectedBorderColor: accent
        )
    }

    private static func makeOptionFormat() -> OnbButtonFormatData {
        OnbButtonFormatData(pressStyle: .press, font: .subheadline, height: .fixed(46), cornerRadius: 12)
    }

    private static func makeSkipStyle() -> OnbButtonStyleType {
        .outline(textColor: .white.opacity(0.45), borderColor: .white.opacity(0.15))
    }

    private static func makeSkipFormat() -> OnbButtonFormatData {
        OnbButtonFormatData(pressStyle: .press, font: .subheadline, height: .fixed(44), cornerRadius: 14)
    }

    // MARK: - Gradient factories

    private static func makeWarmGradient() -> OnbBackgroundType {
        .gradient(
            Gradient(colors: [Color(white: 0.08), Color(red: 0.07, green: 0.04, blue: 0.01)]),
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private static func makeNavyGradient() -> OnbBackgroundType {
        .gradient(
            Gradient(colors: [Color(white: 0.06), Color(red: 0.02, green: 0.04, blue: 0.10)]),
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private static func makePurpleGradient() -> OnbBackgroundType {
        .gradient(
            Gradient(colors: [Color(white: 0.06), Color(red: 0.05, green: 0.02, blue: 0.10)]),
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private static func makeTealGradient() -> OnbBackgroundType {
        .gradient(
            Gradient(colors: [Color(white: 0.06), Color(red: 0.01, green: 0.07, blue: 0.06)]),
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private static func trackSlide(ctaStyle: OnbButtonStyleType, background: OnbBackgroundType) -> OnbSlideType {
        .regular(
            id: "track",
            title: "Your BJJ journal.",
            subtitle: "Log sessions, track submissions, and discover the gaps in your game.",
            media: .bundleImage(named: "waza-logo-white", size: .large, cornerRadius: 0),
            ctaButtonStyle: ctaStyle,
            background: background,
            showBackButton: false
        )
    }

    private static func beltSlide(optionStyle: OnbButtonStyleType, background: OnbBackgroundType) -> OnbSlideType {
        .multipleChoice(
            id: "belt",
            title: "What's your current belt?",
            subtitle: "You can update this anytime in your profile.",
            options: [
                OnbChoiceOption(id: "white", content: OnbButtonContentData(text: "White", secondaryContent: .emoji("⬜️"), secondaryContentPlacement: .leading)),
                OnbChoiceOption(id: "blue", content: OnbButtonContentData(text: "Blue", secondaryContent: .emoji("🟦"), secondaryContentPlacement: .leading)),
                OnbChoiceOption(id: "purple", content: OnbButtonContentData(text: "Purple", secondaryContent: .emoji("🟣"), secondaryContentPlacement: .leading)),
                OnbChoiceOption(id: "brown", content: OnbButtonContentData(text: "Brown", secondaryContent: .emoji("🟫"), secondaryContentPlacement: .leading)),
                OnbChoiceOption(id: "black", content: OnbButtonContentData(text: "Black", secondaryContent: .emoji("⬛️"), secondaryContentPlacement: .leading))
            ],
            optionsButtonStyle: optionStyle,
            selectionBehavior: .single(autoAdvance: true),
            isGrid: false,
            background: background
        )
    }

    private static func notificationsSlide(
        interactor: any OnboardingInteractor,
        ctaStyle: OnbButtonStyleType,
        skipStyle: OnbButtonStyleType,
        background: OnbBackgroundType
    ) -> OnbSlideType {
        .primaryAction(
            id: "notifications",
            title: "Never miss a class.",
            subtitle: "Get a reminder before each session so you always show up ready to train.",
            media: .systemIcon(named: "bell.badge.fill", size: .large),
            ctaText: "Enable Notifications",
            ctaButtonStyle: ctaStyle,
            secondaryButtonText: "Not Now",
            secondaryButtonStyle: skipStyle,
            onDidPressPrimaryButton: { advance in
                Task {
                    _ = try? await interactor.requestPushAuthorization()
                    advance()
                }
            },
            background: background
        )
    }

    private static func locationSlide(
        interactor: any OnboardingInteractor,
        ctaStyle: OnbButtonStyleType,
        skipStyle: OnbButtonStyleType,
        background: OnbBackgroundType
    ) -> OnbSlideType {
        .primaryAction(
            id: "location",
            title: "Auto check-in at your gym.",
            subtitle: "Waza detects when you arrive and logs your attendance automatically. Your location is never stored or shared.",
            media: .systemIcon(named: "location.fill", size: .large),
            ctaText: "Enable Location",
            ctaButtonStyle: ctaStyle,
            secondaryButtonText: "Not Now",
            secondaryButtonStyle: skipStyle,
            onDidPressPrimaryButton: { advance in
                interactor.requestLocationAuthorization()
                advance()
            },
            background: background
        )
    }

    private static func readySlide(ctaStyle: OnbButtonStyleType, background: OnbBackgroundType) -> OnbSlideType {
        .regular(
            id: "ready",
            title: "You're all set.",
            subtitle: "Start logging sessions and watch your game evolve.",
            media: .bundleImage(named: "waza-logo-white", size: .large, cornerRadius: 0),
            ctaText: "Let's Train",
            ctaButtonStyle: ctaStyle,
            background: background
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
