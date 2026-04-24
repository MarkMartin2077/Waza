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

            // Subtle radial glow from the hanko stamp location
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.wazaAccent.opacity(0.12), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 560, height: 560)
                .blur(radius: 40)
                .offset(y: -120)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                heroSection
                    .padding(.top, 100)

                Spacer()

                ctaSection
                    .padding(.horizontal, 24)

                policyLinks
                    .padding(.top, 12)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
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
        VStack(spacing: 24) {
            HankoView(kanji: "技", size: 88, rotation: -3)

            VStack(spacing: 10) {
                Text("Waza")
                    .font(.wazaDisplayLarge)
                    .foregroundStyle(Color.wazaInk900)
                    .tracking(3)

                Text("Your BJJ journey, tracked.")
                    .font(.wazaBody)
                    .italic()
                    .foregroundStyle(Color.wazaInk500)
                    .tracking(0.4)
            }
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 14) {
            Text("Get Started")
                .font(.wazaBody)
                .fontWeight(.medium)
                .foregroundStyle(Color.wazaPaperHi)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .fill(Color.wazaAccent)
                )
                .anyButton(.press) {
                    presenter.onGetStartedPressed()
                }
                .accessibilityIdentifier("StartButton")
                .frame(maxWidth: 500)

            Button("Already have an account? Sign In") {
                presenter.onSignInPressed()
            }
            .font(.wazaBody)
            .foregroundStyle(Color.wazaInk500)
        }
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
