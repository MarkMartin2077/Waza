import SwiftUI

struct OnboardingView: View {

    @State var presenter: OnboardingPresenter
    let delegate: OnboardingDelegate

    @Namespace private var indicatorNamespace

    var body: some View {
        ZStack {
            background

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
        }
        .preferredColorScheme(.dark)
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
            Color.black.ignoresSafeArea()

            Circle()
                .fill(RadialGradient(
                    colors: [beltColor.opacity(0.3), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 240
                ))
                .frame(width: 480, height: 480)
                .offset(x: CGFloat(presenter.currentPage - 3) * 28, y: -160)
                .animation(.easeInOut(duration: 0.7), value: presenter.currentPage)

            Circle()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(0.04), Color.clear],
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

    private var beltColor: Color {
        .wazaAccent
    }

    // MARK: - Top Controls

    private var skipButton: some View {
        HStack {
            Text("Skip")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
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
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 8, height: 8)

                    if index == presenter.currentPage {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 24, height: 8)
                            .matchedGeometryEffect(id: "pill", in: indicatorNamespace)
                    }
                }
                .frame(width: index == presenter.currentPage ? 24 : 8, height: 8)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: presenter.currentPage)
            }
        }
    }

    // MARK: - Bottom Buttons

    @ViewBuilder
    private var bottomArea: some View {
        switch presenter.currentPage {
        case 4:
            permissionButtons(
                primaryLabel: "Enable Notifications",
                onPrimary: { presenter.onEnableNotificationsTapped() },
                onSkip: { presenter.onSkipNotificationsTapped() }
            )
        case 5:
            permissionButtons(
                primaryLabel: "Enable Location",
                onPrimary: { presenter.onEnableLocationTapped() },
                onSkip: { presenter.onSkipLocationTapped() }
            )
        case 6:
            finishButton
        default:
            continueButton
        }
    }

    private var continueButton: some View {
        Text("Continue")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.wazaAccent)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .anyButton(.press) {
                presenter.onContinuePressed()
            }
    }

    private var finishButton: some View {
        ZStack {
            if presenter.isCompletingOnboarding {
                ProgressView().tint(.white)
            } else {
                Text("Let's Train")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.wazaAccent)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .anyButton(.press) {
            if !presenter.isCompletingOnboarding {
                presenter.onFinishPressed()
            }
        }
    }

    private func permissionButtons(
        primaryLabel: String,
        onPrimary: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 10) {
            Text(primaryLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.wazaAccent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .anyButton(.press) { onPrimary() }

            Text("Not Now")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.45))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .anyButton(.press) { onSkip() }
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(beltColor.opacity(0.1))
                    .frame(width: 160, height: 160)
                Circle()
                    .strokeBorder(beltColor.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 160, height: 160)
                Image(systemName: "figure.wrestling")
                    .font(.system(size: 60, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(beltColor)
            }

            Color.clear.frame(height: 44)

            VStack(spacing: 14) {
                Text("Welcome to Waza.")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Track every mat session.\nMeasure your growth. Earn your next belt.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
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
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Just your first name.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
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
            .foregroundStyle(Color.black)
            .font(.body)
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text("We'll track your progress each week.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Color.clear.frame(height: 24)

            VStack(spacing: 10) {
                goalRow(id: "2", label: "1–2×", detail: "Light schedule")
                goalRow(id: "3", label: "3×", detail: "Consistent")
                goalRow(id: "4", label: "4×", detail: "Dedicated")
                goalRow(id: "5", label: "5×+", detail: "Competitor")
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func goalRow(id: String, label: String, detail: String) -> some View {
        let isSelected = presenter.selectedGoalId == id

        return HStack(spacing: 14) {
            Text(label)
                .font(.title3.weight(.bold))
                .foregroundStyle(isSelected ? beltColor : .white)
                .frame(width: 52, alignment: .leading)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(beltColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? beltColor.opacity(0.15) : Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? beltColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isSelected)
        .anyButton(.press) {
            presenter.onGoalSelected(id)
        }
    }

    private func permissionPage(
        iconName: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 120, height: 120)
                Circle()
                    .strokeBorder(iconColor.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 120, height: 120)
                Image(systemName: iconName)
                    .font(.system(size: 46, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
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
            iconColor: Color(red: 0.65, green: 0.45, blue: 1.0),
            title: "Never miss a class.",
            subtitle: "Get a reminder before each session so you always show up ready to train."
        )
    }

    private var locationPage: some View {
        permissionPage(
            iconName: "location.fill",
            iconColor: Color(red: 0.2, green: 0.8, blue: 0.7),
            title: "Auto check-in at your gym.",
            subtitle: "Waza detects when you arrive and logs your attendance automatically.\n\nYour location is never stored or shared."
        )
    }

    private var readyPage: some View {
        VStack(spacing: 36) {
            ZStack {
                Circle()
                    .fill(beltColor.opacity(0.12))
                    .frame(width: 120, height: 120)
                Circle()
                    .strokeBorder(beltColor.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(beltColor)
            }

            VStack(spacing: 12) {
                Text("You're all set.")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("The mats are waiting.\nTime to track your journey.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
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
