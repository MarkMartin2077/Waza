import SwiftUI

struct SettingsView: View {

    @State var presenter: SettingsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                profileHeader
                accountCard
                purchaseCard
                appInfoCard
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

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(presenter.beltAccentColor.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay {
                    Circle()
                        .stroke(presenter.beltAccentColor, lineWidth: 2)
                    Text(presenter.userName.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(presenter.beltAccentColor)
                }

            VStack(spacing: 4) {
                Text(presenter.userName)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(presenter.beltDisplayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(presenter.beltAccentColor.opacity(0.12), in: Capsule())
                    .foregroundStyle(presenter.beltAccentColor)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Account Card

    private var accountCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Account")

            if presenter.isAnonymousUser {
                settingsRow(
                    icon: "person.crop.circle.badge.plus",
                    iconColor: presenter.beltAccentColor,
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

            Divider().padding(.leading, 52)

            settingsRow(
                icon: "trash",
                iconColor: .red,
                label: "Delete account",
                labelColor: .red,
                action: { presenter.onDeleteAccountPressed() }
            )
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Purchase Card

    private var purchaseCard: some View {
        VStack(spacing: 0) {
            sectionHeader("Membership")

            HStack(spacing: 14) {
                settingsIcon(systemName: presenter.isPremium ? "star.fill" : "star", color: .yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text(presenter.isPremium ? "Waza Premium" : "Free Plan")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(presenter.isPremium ? "Active subscription" : "Upgrade to unlock all features")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if presenter.isPremium {
                    Text("MANAGE")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
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
                iconColor: presenter.beltAccentColor,
                label: "Contact us",
                labelColor: presenter.beltAccentColor,
                action: { presenter.onContactUsPressed() }
            )

            Divider()
                .padding(.leading, 52)

            Text("© 2025 Waza. All rights reserved.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
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
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        label: String,
        labelColor: Color = .primary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
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
        }
        .buttonStyle(.plain)
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
