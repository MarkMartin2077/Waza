import SwiftUI

struct SettingsView: View {

    @State var presenter: SettingsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                appearanceCard
                accountCard
                purchaseCard
                storeCard
                appInfoCard
                dangerZoneCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .navigationTitle("Settings")
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

            if presenter.isAnonymousUser {
                settingsRow(
                    icon: "person.crop.circle.badge.plus",
                    iconColor: Color.wazaAccent,
                    label: "Save & back-up account",
                    action: { presenter.onCreateAccountPressed() }
                )
            } else {
                settingsRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    iconColor: .orange,
                    label: "Sign out",
                    action: { presenter.onSignOutPressed() }
                )
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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

    // MARK: - Purchase Card

    private var purchaseCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Membership")

            if presenter.isPremium {
                settingsRow(
                    icon: "creditcard",
                    iconColor: Color.wazaAccent,
                    label: "Manage Subscription",
                    action: { presenter.onManageSubscriptionPressed() }
                )
            } else {
                settingsRow(
                    icon: "arrow.up.circle",
                    iconColor: Color.wazaAccent,
                    label: "Upgrade to Premium",
                    labelColor: Color.wazaAccent,
                    action: { presenter.onUpgradeToPremiumPressed() }
                )
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
                item: URL(string: "https://apps.apple.com/app/id6759821384")!,
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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

    private func settingsLinkRow(icon: String, iconColor: Color, label: String, urlString: String) -> some View {
        Link(destination: URL(string: urlString)!) {
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
