//
//  WelcomeBackView.swift
//  Waza
//
import SwiftUI
import SwiftfulRouting

struct WelcomeBackDelegate {
    var isNewUser: Bool = false
    var kanji: String {
        isNewUser ? "始" : "還"
    }
    var onComplete: (() -> Void)?

    var eventParameters: [String: Any]? {
        ["is_new_user": isNewUser]
    }
}

struct WelcomeBackView: View {

    @State var presenter: WelcomeBackPresenter
    let delegate: WelcomeBackDelegate

    var body: some View {
        ZStack {
            Color.wazaPaper.ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.wazaAccent.opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 560, height: 560)
                .blur(radius: 40)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                HankoView(kanji: delegate.kanji, size: 108, rotation: -4)
                    .scaleEffect(presenter.showContent ? 1.0 : 0.3)
                    .opacity(presenter.showContent ? 1.0 : 0.0)
                    .rotationEffect(.degrees(presenter.showContent ? 0 : -12))

                VStack(spacing: 8) {
                    Text(delegate.isNewUser ? "Welcome" : "Welcome back")
                        .font(.wazaDisplaySmall)
                        .foregroundStyle(Color.wazaInk500)
                        .italic()

                    Text(presenter.name)
                        .font(.wazaDisplayLarge)
                        .foregroundStyle(Color.wazaInk900)
                        .tracking(1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .opacity(presenter.showContent ? 1.0 : 0.0)
                .offset(y: presenter.showContent ? 0 : 12)
            }
            .padding(.horizontal, 32)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            presenter.onViewTapped(delegate: delegate)
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
    }
}

extension CoreBuilder {

    func welcomeBackView(router: AnyRouter, delegate: WelcomeBackDelegate) -> some View {
        WelcomeBackView(
            presenter: WelcomeBackPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showWelcomeBackView(delegate: WelcomeBackDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.welcomeBackView(router: router, delegate: delegate)
        }
    }

}

#Preview("Returning") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.welcomeBackView(
            router: router,
            delegate: WelcomeBackDelegate(isNewUser: false)
        )
    }
}

#Preview("New user") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.welcomeBackView(
            router: router,
            delegate: WelcomeBackDelegate(isNewUser: true)
        )
    }
}
