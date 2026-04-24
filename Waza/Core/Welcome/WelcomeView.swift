import SwiftUI

struct WelcomeDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct WelcomeView: View {

    @State var presenter: WelcomePresenter
    let delegate: WelcomeDelegate

    var body: some View {
        ZStack {
            Color.wazaPaper.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                heroSection

                Spacer(minLength: 40)

                featureList

                Spacer(minLength: 40)

                ctaSection

                policyLinks
                    .padding(.top, 18)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            HankoView(kanji: "技", size: 72, rotation: -3)

            VStack(spacing: 6) {
                Text("Waza")
                    .font(.wazaDisplayLarge)
                    .foregroundStyle(Color.wazaInk900)
                    .tracking(3)

                Text("Your BJJ journey, tracked.")
                    .font(.wazaBody)
                    .italic()
                    .foregroundStyle(Color.wazaInk500)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Features

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 20) {
            featureRow(
                kanji: "録",
                title: "Log every session",
                subtitle: "Capture technique, mood, and mat time."
            )
            featureRow(
                kanji: "連",
                title: "Build your streak",
                subtitle: "Weekly challenges keep you coming back."
            )
            featureRow(
                kanji: "道",
                title: "Map your path",
                subtitle: "Track techniques from learning to mastery."
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func featureRow(kanji: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            HankoView(kanji: kanji, size: 36, rotation: -2)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.wazaInk900)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.wazaInk500)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 14) {
            Text("Get Started")
                .font(.wazaBody)
                .fontWeight(.semibold)
                .foregroundStyle(Color.wazaPaperHi)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .fill(Color.wazaAccent)
                )
                .anyButton(.press) {
                    presenter.onGetStartedPressed()
                }
                .accessibilityIdentifier("StartButton")

            continueAsGuestButton
        }
    }

    private var continueAsGuestButton: some View {
        HStack(spacing: 6) {
            if presenter.isGuestContinuing {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(Color.wazaInk500)
            }
            Text(presenter.isGuestContinuing ? "Just a moment…" : "Continue without signing in")
                .font(.wazaLabel)
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(Color.wazaInk500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .accessibilityIdentifier("ContinueAsGuestButton")
        .anyButton {
            presenter.onContinueAsGuestPressed()
        }
        .disabled(presenter.isGuestContinuing)
    }

    // MARK: - Policy

    private var policyLinks: some View {
        HStack(spacing: 8) {
            if let url = URL(string: Constants.termsOfServiceUrlString) {
                Link(destination: url) {
                    Text("Terms of Service")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            Circle()
                .fill(Color.wazaInk400)
                .frame(width: 3, height: 3)
            if let url = URL(string: Constants.privacyPolicyUrlString) {
                Link(destination: url) {
                    Text("Privacy Policy")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .wazaLabelStyle()
        .foregroundStyle(Color.wazaInk400)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return builder.onboardingFlow()
}

extension CoreBuilder {

    func onboardingFlow() -> some View {
        RouterView { router in
            welcomeView(router: router)
        }
    }

    private func welcomeView(router: AnyRouter, delegate: WelcomeDelegate = WelcomeDelegate()) -> some View {
        WelcomeView(
            presenter: WelcomePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

}
