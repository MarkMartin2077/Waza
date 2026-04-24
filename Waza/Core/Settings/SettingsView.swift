import SwiftUI

struct SettingsView: View {

    @State var presenter: SettingsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                appearanceCard
                accountCard
                storeCard
                appInfoCard
                dangerZoneCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
        .background(Color.wazaPaper)
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarBackground(Color.wazaPaper, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }

    // MARK: - Account Card

    private var accountCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Account")

            identityRow

            Divider().padding(.leading, 16)

            if presenter.isAnonymousUser {
                saveAccountButton
            } else {
                signOutButton
            }
        }
        .wazaCard()
    }

    private var identityRow: some View {
        HStack(spacing: 14) {
            identityAvatar

            VStack(alignment: .leading, spacing: 2) {
                Text(presenter.isAnonymousUser ? "Anonymous Grappler" : presenter.userName)
                    .font(.wazaBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.wazaInk900)
                    .lineLimit(1)

                if let email = presenter.userEmail {
                    Text(email)
                        .font(.wazaLabel)
                        .foregroundStyle(Color.wazaInk500)
                        .lineLimit(1)
                } else if presenter.isAnonymousUser {
                    Text("Not signed in")
                        .font(.wazaLabel)
                        .foregroundStyle(Color.wazaInk500)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let label = presenter.authProviderLabel, let icon = presenter.authProviderIcon {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(label.uppercased())
                        .font(.wazaLabel)
                }
                .foregroundStyle(Color.wazaInk600)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .fill(Color.wazaInk100)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var identityAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.wazaAccent.opacity(0.15))
            Text(presenter.userInitial)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Color.wazaAccent)
        }
        .frame(width: 36, height: 36)
    }

    private var saveAccountButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 14, weight: .semibold))
            Text("Save & back up account")
                .font(.wazaBody)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color.wazaPaperHi)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(Color.wazaAccent)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .anyButton(.press) {
            presenter.onCreateAccountPressed()
        }
    }

    private var signOutButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 14, weight: .semibold))
            Text("Sign out")
                .font(.wazaBody)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color.orange)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(Color.orange.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .strokeBorder(Color.orange.opacity(0.25), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .anyButton(.press) {
            presenter.onSignOutPressed()
        }
    }

    // MARK: - Danger Zone Card

    private var dangerZoneCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Danger Zone")

            settingsRow(
                icon: "trash",
                iconColor: .red,
                label: "Delete account",
                labelColor: .red,
                action: { presenter.onDeleteAccountPressed() }
            )
        }
        .background(Color.red.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - App Info Card

    private var appInfoCard: some View {
        VStack(spacing: 0) {
            sectionHeader("App")

            settingsInfoRow(
                icon: "info.circle",
                iconColor: .blue,
                label: "Version",
                value: Utilities.appVersion ?? "—"
            )

            Divider().padding(.leading, 52)

            settingsInfoRow(
                icon: "hammer",
                iconColor: .gray,
                label: "Build",
                value: Utilities.buildNumber ?? "—"
            )

            Divider().padding(.leading, 52)

            settingsRow(
                icon: "envelope",
                iconColor: Color.wazaAccent,
                label: "Contact us",
                labelColor: Color.wazaAccent,
                action: { presenter.onContactUsPressed() }
            )

            Divider().padding(.leading, 52)

            settingsLinkRow(icon: "questionmark.circle", iconColor: .blue, label: "Support", urlString: Constants.supportUrlString)

            Divider().padding(.leading, 52)

            settingsLinkRow(icon: "doc.text", iconColor: .gray, label: "Terms of Service", urlString: Constants.termsOfServiceUrlString)

            Divider().padding(.leading, 52)

            settingsLinkRow(icon: "hand.raised", iconColor: .gray, label: "Privacy Policy", urlString: Constants.privacyPolicyUrlString)

            Divider()
                .padding(.leading, 52)

            Text("© 2026 Mark Martin. All rights reserved.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .wazaCard()
    }

    // MARK: - Appearance Card

    private var appearanceCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Appearance")

            HStack(spacing: 14) {
                settingsIcon(systemName: "moon.circle.fill", color: .indigo)
                Text("Color Scheme")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Color Scheme", selection: Binding(
                    get: { presenter.colorSchemeIndex },
                    set: { presenter.colorSchemeIndex = $0 }
                )) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 186)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().padding(.leading, 52)

            settingsRow(
                icon: "bell.badge",
                iconColor: .red,
                label: "Notifications",
                action: { presenter.onNotificationsSettingsPressed() }
            )
        }
        .wazaCard()
    }

    // MARK: - Store Card

    private var storeCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Support Us")

            settingsRow(
                icon: "star.fill",
                iconColor: .yellow,
                label: "Rate the App",
                action: { presenter.onRateAppPressed() }
            )

            Divider().padding(.leading, 52)

            ShareLink(
                item: URL(string: "https://apps.apple.com/app/id6759821384") ?? URL(string: "https://apple.com")!,
                message: Text("Check out Waza — the best BJJ training tracker!")
            ) {
                HStack(spacing: 14) {
                    settingsIcon(systemName: "square.and.arrow.up", color: Color.wazaAccent)
                    Text("Share the App")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { presenter.onShareAppPressed() })
        }
        .wazaCard()
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 6)
    }

    private func settingsIcon(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.subheadline)
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        label: String,
        labelColor: Color = .primary,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 14) {
            settingsIcon(systemName: icon, color: iconColor)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(labelColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .anyButton(.press) {
            action()
        }
    }

    private func settingsInfoRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            settingsIcon(systemName: icon, color: iconColor)
            Text(label)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func settingsLinkRow(icon: String, iconColor: Color, label: String, urlString: String) -> some View {
        if let url = URL(string: urlString) {
            Link(destination: url) {
                HStack(spacing: 14) {
                    settingsIcon(systemName: icon, color: iconColor)
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }
}

#Preview("No auth") {
    let container = DevPreview.shared.container()
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.settingsView(router: router)
    }
}
#Preview("Anonymous") {
    let container = DevPreview.shared.container()
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.settingsView(router: router)
    }
}
#Preview("Not anonymous") {
    let container = DevPreview.shared.container()
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.settingsView(router: router)
    }
}

extension CoreBuilder {

    func settingsView(router: AnyRouter) -> some View {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

}

extension CoreRouter {

    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView(router: router)
        }
    }

}
