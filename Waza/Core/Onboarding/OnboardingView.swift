import SwiftUI

struct OnboardingView: View {

    @State var presenter: OnboardingPresenter
    let delegate: OnboardingDelegate

    @Namespace private var indicatorNamespace

    var body: some View {
        VStack(spacing: 0) {
            skipButton
                .padding()

            TabView(selection: $presenter.currentPage) {
                welcomePage.tag(0)
                namePage.tag(1)
                trainingGoalPage.tag(2)
                notificationsPage.tag(3)
                locationPage.tag(4)
                readyPage.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.35), value: presenter.currentPage)
            .onChange(of: presenter.currentPage) { _, newPage in
                presenter.onPageChanged(newPage)
            }

            pageIndicator
                .padding(.top, 20)

            bottomArea
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
        }
        // `.background` modifier — the background fits *behind* the content without
        // contributing to the content's layout width. Previously the 480pt background
        // circle was forcing the whole hierarchy to 480pt wide and clipping right-edge
        // content on iPhone 15 Pro (393pt) and smaller devices.
        .background(background)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.wazaPaper.ignoresSafeArea()

            Circle()
                .fill(RadialGradient(
                    colors: [accentColor.opacity(0.14), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 240
                ))
                .frame(width: 480, height: 480)
                .offset(x: CGFloat(presenter.currentPage - 3) * 28, y: -160)
                .animation(.easeInOut(duration: 0.7), value: presenter.currentPage)

            Circle()
                .fill(RadialGradient(
                    colors: [Color.wazaInk300.opacity(0.25), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 360)
                .offset(x: CGFloat(3 - presenter.currentPage) * 22, y: 220)
                .animation(.easeInOut(duration: 0.9), value: presenter.currentPage)
        }
        .ignoresSafeArea()
    }

    private var accentColor: Color {
        .wazaAccent
    }

    // MARK: - Top Controls

    private var skipButton: some View {
        HStack {
            Text("Skip")
                .wazaLabelStyle()
                .padding(.trailing, 20)
                .anyButton(.press) {
                    presenter.onSkipPressed()
                }
                .opacity(presenter.isLastPage ? 0 : 1)
                .animation(.easeInOut(duration: 0.22), value: presenter.isLastPage)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 44)
        .padding(.top, 56)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<OnboardingPresenter.totalPages, id: \.self) { index in
                Group {
                    if index == presenter.currentPage {
                        Capsule()
                            .fill(Color.wazaInk900)
                            .frame(width: 24, height: 8)
                            .matchedGeometryEffect(id: "pill", in: indicatorNamespace)
                    } else {
                        Capsule()
                            .fill(Color.wazaInk300)
                            .frame(width: 8, height: 8)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: presenter.currentPage)
            }
        }
    }

    // MARK: - Bottom Buttons

    @ViewBuilder
    private var bottomArea: some View {
        // Page tags: 0 welcome, 1 name, 2 goal, 3 notifications, 4 location, 5 ready.
        // All pages use the same single-button layout for consistent bottom positioning.
        switch presenter.currentPage {
        case 3:
            primaryButton(label: "Enable Notifications") {
                presenter.onEnableNotificationsTapped()
            }
        case 4:
            primaryButton(label: "Enable Location") {
                presenter.onEnableLocationTapped()
            }
        case 5:
            finishButton
        default:
            continueButton
        }
    }

    private var continueButton: some View {
        Text("Continue")
            .font(.wazaBody)
            .fontWeight(.medium)
            .foregroundStyle(Color.wazaPaperHi)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(Color.wazaAccent)
            )
            .anyButton(.press) {
                presenter.onContinuePressed()
            }
    }

    private var finishButton: some View {
        ZStack {
            if presenter.isCompletingOnboarding {
                ProgressView().tint(Color.wazaPaperHi)
            } else {
                Text("Let's Train")
                    .font(.wazaBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.wazaPaperHi)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(Color.wazaAccent)
        )
        .anyButton(.press) {
            if !presenter.isCompletingOnboarding {
                presenter.onFinishPressed()
            }
        }
    }

    private func primaryButton(label: String, action: @escaping () -> Void) -> some View {
        Text(label)
            .font(.wazaBody)
            .fontWeight(.medium)
            .foregroundStyle(Color.wazaPaperHi)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(Color.wazaAccent)
            )
            .anyButton(.press) { action() }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 0) {
            HankoView(kanji: "始", size: 120, rotation: -3)

            Color.clear.frame(height: 44)

            VStack(spacing: 14) {
                Text("Welcome to Waza.")
                    .font(.wazaDisplayLarge)
                    .italic()
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)

                Text("Track every mat session.\nMeasure your growth. Earn your next belt.")
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaInk500)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var namePage: some View {
        VStack(spacing: 36) {
            VStack(spacing: 10) {
                Text("What should we call you?")
                    .font(.wazaDisplayMedium)
                    .italic()
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)
                Text("Just your first name.")
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaInk500)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            TextField(
                "Your name",
                text: Binding(
                    get: { presenter.enteredName },
                    set: { presenter.enteredName = $0 }
                )
            )
            .foregroundStyle(Color.wazaInk900)
            .font(.wazaDisplaySmall)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(Color.wazaPaperHi)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
            )
            .padding(.horizontal, 24)
            .submitLabel(.done)
            .onSubmit {
                presenter.onContinuePressed()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var trainingGoalPage: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 8)

            VStack(spacing: 8) {
                Text("How often do you want to train?")
                    .font(.wazaDisplayMedium)
                    .italic()
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text("We'll track your progress each week.")
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaInk500)
            }

            Color.clear.frame(height: 24)

            VStack(spacing: 10) {
                goalRow(id: "2", label: "1–2×", detail: "Light schedule")
                goalRow(id: "3", label: "3×", detail: "Consistent")
                goalRow(id: "4", label: "4×", detail: "Dedicated")
                goalRow(id: "5", label: "5×+", detail: "Competitor")
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func goalRow(id: String, label: String, detail: String) -> some View {
        let isSelected = presenter.selectedGoalId == id

        return HStack(spacing: 14) {
            Text(label)
                .font(.wazaDisplaySmall)
                .foregroundStyle(isSelected ? accentColor : Color.wazaInk900)
                .frame(width: 60, alignment: .leading)

            Text(detail)
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk500)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(accentColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerStandard)
                .fill(isSelected ? accentColor.opacity(0.1) : Color.wazaPaperHi)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .wazaCornerStandard)
                .strokeBorder(isSelected ? accentColor : Color.wazaInk300, lineWidth: isSelected ? 1.5 : 0.5)
        )
        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isSelected)
        .anyButton(.press) {
            presenter.onGoalSelected(id)
        }
    }

    private func permissionPage(
        iconName: String,
        title: String,
        subtitle: String
    ) -> some View {
        VStack(spacing: 40) {
            ZStack {
                RoundedRectangle(cornerRadius: .wazaCornerStandard)
                    .fill(Color.wazaPaperHi)
                    .frame(width: 120, height: 120)
                RoundedRectangle(cornerRadius: .wazaCornerStandard)
                    .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
                    .frame(width: 120, height: 120)
                Image(systemName: iconName)
                    .font(.system(size: 46, weight: .regular))
                    .foregroundStyle(accentColor)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.wazaDisplayMedium)
                    .italic()
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaInk500)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notificationsPage: some View {
        permissionPage(
            iconName: "bell.badge.fill",
            title: "Never miss a class.",
            subtitle: "Get a reminder before each session so you always show up ready to train."
        )
    }

    private var locationPage: some View {
        permissionPage(
            iconName: "location.fill",
            title: "Auto check-in at your gym.",
            subtitle: "Waza detects when you arrive and logs your attendance automatically.\n\nYour location is never stored or shared."
        )
    }

    private var readyPage: some View {
        VStack(spacing: 36) {
            HankoView(kanji: "道", size: 120, rotation: -2)

            VStack(spacing: 12) {
                Text("You're all set.")
                    .font(.wazaDisplayLarge)
                    .italic()
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)
                Text("The mats are waiting.\nTime to track your journey.")
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaInk500)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Welcome Page") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.onboardingView(router: router, delegate: OnboardingDelegate())
    }
}

#Preview("Name Page") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        let presenter = OnboardingPresenter(
            interactor: CoreInteractor(container: container),
            router: CoreRouter(router: router, builder: builder)
        )
        presenter.currentPage = 1
        return OnboardingView(presenter: presenter, delegate: OnboardingDelegate())
    }
}

#Preview("Ready Page") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        let presenter = OnboardingPresenter(
            interactor: CoreInteractor(container: container),
            router: CoreRouter(router: router, builder: builder)
        )
        presenter.currentPage = 5
        return OnboardingView(presenter: presenter, delegate: OnboardingDelegate())
    }
}

// MARK: - CoreBuilder

extension CoreBuilder {

    func onboardingView(router: AnyRouter, delegate: OnboardingDelegate = OnboardingDelegate()) -> some View {
        OnboardingView(
            presenter: OnboardingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

// MARK: - CoreRouter

extension CoreRouter {

    func showOnboardingView() {
        router.showScreen(.fullScreenCover) { router in
            builder.onboardingView(router: router, delegate: OnboardingDelegate())
        }
    }
}
