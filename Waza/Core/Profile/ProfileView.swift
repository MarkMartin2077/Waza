import SwiftUI

struct ProfileDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ProfileView: View {

    @State var presenter: ProfilePresenter
    let delegate: ProfileDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                    .scaleAppear(delay: 0)
                XPProgressBarView(
                    levelInfo: presenter.xpLevelInfo,
                    accentColor: .wazaAccent
                )
                .scaleAppear(delay: 0.03)
                ActiveBoostView(
                    streakTier: presenter.streakTier,
                    fireRoundExpiresAt: presenter.fireRoundExpiresAt,
                    perfectWeekActive: presenter.perfectWeekActive
                )
                .scaleAppear(delay: 0.04)
                statsSection
                    .scaleAppear(delay: 0.06)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            // Separate ToolbarItems so iOS 26 renders each as its own liquid-glass capsule.
            if let image = presenter.shareCardImage {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("My Waza Stats", image: Image(uiImage: image))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(Color.wazaAccent)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            avatar

            Text(presenter.userName)
                .font(.wazaDisplayMedium)

            if presenter.isPremium {
                Label("Premium", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.15), in: Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.wazaAccent.opacity(0.15))
                .frame(width: 80, height: 80)

            Text(presenter.avatarInitials)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.wazaAccent)
        }
        .accessibilityLabel("Profile avatar")
    }

    // MARK: - Stats

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            profileStat(value: "\(presenter.streakCount)", label: "Day Streak")
            profileStat(value: "\(presenter.sessionStats.thisWeekSessions)", label: "This Week")
            profileStat(value: "\(presenter.sessionStats.totalSessions)", label: "Sessions")
            profileStat(value: presenter.totalTrainingHoursText, label: "Hrs Trained")
        }
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.wazaNumSmall)
                .foregroundStyle(Color.wazaInk900)
                .contentTransition(.numericText())
            Text(label)
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .wazaCard()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(Color.wazaAccent)
            .anyButton(.press) {
                presenter.onSettingsButtonPressed()
            }
            .accessibilityLabel("Settings")
    }
}

#Preview("Full Profile") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProfileDelegate()

    return RouterView { router in
        builder.profileView(router: router, delegate: delegate)
    }
}

#Preview("Empty State") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProfileDelegate()

    return RouterView { router in
        builder.profileView(router: router, delegate: delegate)
    }
}

#Preview("No Belt Set") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.profileView(router: router)
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func profileView(router: AnyRouter, delegate: ProfileDelegate = ProfileDelegate()) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showProfileView(delegate: ProfileDelegate) {
        router.showScreen(.push) { router in
            builder.profileView(router: router, delegate: delegate)
        }
    }

}
