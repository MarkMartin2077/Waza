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
            // Slightly lifted base so the bottom half isn't pure black
            Color(white: 0.04).ignoresSafeArea()

            // Diffuse glow centred on where the logo sits (~35% down the screen)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.wazaAccent.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 560, height: 560)
                .blur(radius: 40)
                .offset(y: -120)
                .ignoresSafeArea()

            // frame(maxWidth: .infinity) anchors the VStack to full screen width
            // so all children are laid out against real screen edges
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
        .preferredColorScheme(.dark)
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
            // App icon with glow
            ZStack {
                Circle()
                    .fill(Color.wazaAccent.opacity(0.35))
                    .frame(width: 140, height: 140)
                    .blur(radius: 36)

                Image("waza-logo-white")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            VStack(spacing: 10) {
                Text("Waza")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(3)

                Text("Your BJJ journey, tracked.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(0.4)
            }
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 14) {
            Text("Get Started")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.wazaAccent, in: Capsule())
                .anyButton(.press) {
                    presenter.onGetStartedPressed()
                }
                .accessibilityIdentifier("StartButton")
                .frame(maxWidth: 500)

            Button("Already have an account? Sign In") {
                presenter.onSignInPressed()
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.45))
        }
    }

    // MARK: - Policy

    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceUrlString)!) {
                Text("Terms of Service")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Circle()
                .fill(.white.opacity(0.25))
                .frame(width: 3, height: 3)
            Link(destination: URL(string: Constants.privacyPolicyUrlString)!) {
                Text("Privacy Policy")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .font(.caption2)
        .foregroundStyle(.white.opacity(0.25))
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
