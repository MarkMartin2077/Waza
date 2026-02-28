import SwiftUI
import SwiftfulOnboarding

struct OnboardingView: View {

    @State var presenter: OnboardingPresenter
    let delegate: OnboardingDelegate

    var body: some View {
        SwiftfulOnboardingView(configuration: presenter.configuration)
            .preferredColorScheme(.dark)
            .overlay(alignment: .topTrailing) {
                Button("Skip") {
                    presenter.onSkipPressed()
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, 56)
                .padding(.trailing, 20)
            }
            .onAppear {
                presenter.onViewAppear(delegate: delegate)
            }
            .onDisappear {
                presenter.onViewDisappear(delegate: delegate)
            }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.onboardingView(router: router, delegate: OnboardingDelegate())
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
