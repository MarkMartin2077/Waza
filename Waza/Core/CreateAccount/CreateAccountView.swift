//
//  CreateAccountView.swift
//
//
//
//
import SwiftUI
import SwiftfulAuthUI
import SwiftfulRouting

struct CreateAccountDelegate {
    var title: String = "Save your journey"
    var subtitle: String = "Sign in to back up your sessions and sync across devices."
    var kanji: String = "入"
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?

    var eventParameters: [String: Any]? {
        [
            "delegate_title": title,
            "delegate_subtitle": subtitle
        ]
    }
}

struct CreateAccountView: View {

    @State var presenter: CreateAccountPresenter
    var delegate: CreateAccountDelegate = CreateAccountDelegate()

    var body: some View {
        ZStack(alignment: .top) {
            Color.wazaPaper.ignoresSafeArea()

            // Subtle accent wash behind the hanko
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.wazaAccent.opacity(0.10), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 240
                    )
                )
                .frame(width: 480, height: 480)
                .blur(radius: 36)
                .offset(y: -140)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Spacer(minLength: 12)

                heroSection
                    .padding(.horizontal, 24)

                Spacer(minLength: 24)

                buttonStack
                    .padding(.horizontal, 24)

                policyFooter
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Header

    private var header: some View {
        Image(systemName: "xmark")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.wazaInk700)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(Color.wazaPaperHi)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
                    )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .anyButton(.press) {
                presenter.onDismissPressed()
            }
            .accessibilityLabel("Close")
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 24) {
            HankoView(kanji: delegate.kanji, size: 76, rotation: -3)

            VStack(spacing: 10) {
                Text(delegate.title)
                    .font(.wazaDisplayMedium)
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(delegate.subtitle)
                    .font(.wazaBody)
                    .italic()
                    .foregroundStyle(Color.wazaInk500)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .tracking(0.2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 340)
        }
    }

    // MARK: - Buttons

    private var buttonStack: some View {
        VStack(spacing: 12) {
            appleButton
            googleButton
        }
        .frame(maxWidth: 500)
    }

    private var appleButton: some View {
        ZStack {
            SignInAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: .wazaCornerSmall
            )
            .opacity(presenter.activeProvider == .apple ? 0 : 1)

            if presenter.activeProvider == .apple {
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(Color.wazaInk900)
                    .overlay(
                        ProgressView()
                            .tint(Color.wazaPaperHi)
                    )
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .anyButton(.press) {
            presenter.onSignInApplePressed(delegate: delegate)
        }
        .disabled(presenter.activeProvider != nil)
        .accessibilityIdentifier("AppleSignInButton")
    }

    private var googleButton: some View {
        ZStack {
            SignInGoogleButtonView(
                type: .signIn,
                backgroundColor: .googleRed,
                cornerRadius: .wazaCornerSmall
            )
            .opacity(presenter.activeProvider == .google ? 0 : 1)

            if presenter.activeProvider == .google {
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(Color.googleRed)
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .anyButton(.press) {
            presenter.onSignInGooglePressed(delegate: delegate)
        }
        .disabled(presenter.activeProvider != nil)
        .accessibilityIdentifier("GoogleSignInButton")
    }

    // MARK: - Policy Footer

    private var policyFooter: some View {
        VStack(spacing: 10) {
            Text("By continuing, you agree to our")
                .font(.wazaLabel)
                .foregroundStyle(Color.wazaInk400)

            HStack(spacing: 8) {
                if let url = URL(string: Constants.termsOfServiceUrlString) {
                    Link(destination: url) {
                        Text("Terms of Service")
                            .lineLimit(1)
                    }
                }
                Circle()
                    .fill(Color.wazaInk400)
                    .frame(width: 3, height: 3)
                if let url = URL(string: Constants.privacyPolicyUrlString) {
                    Link(destination: url) {
                        Text("Privacy Policy")
                            .lineLimit(1)
                    }
                }
            }
            .wazaLabelStyle()
            .foregroundStyle(Color.wazaInk500)
        }
        .frame(maxWidth: .infinity)
    }
}

extension CoreBuilder {

    func createAccountView(router: AnyRouter, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)? = nil) {
        router.showScreen(.fullScreenCover) { sheetRouter in
            builder.createAccountView(router: sheetRouter, delegate: delegate)
        }
    }

}

#Preview("Sign In") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.createAccountView(router: router)
    }
}

#Preview("Save Account") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.createAccountView(
            router: router,
            delegate: CreateAccountDelegate(
                title: "Save your journey",
                subtitle: "Back up your sessions and sync across every device.",
                kanji: "守"
            )
        )
    }
}
