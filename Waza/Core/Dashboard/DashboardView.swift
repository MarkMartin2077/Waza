import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                greetingHeader
                logSessionButton

                if presenter.isNewUser {
                    activationCard
                } else {
                    thisWeekSection
                }

                upcomingClassSection
                recentSessionsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .toolbar {
            #if !PROD
            ToolbarItem(placement: .topBarTrailing) {
                devSettingsButton
            }
            #endif
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        Text(presenter.greetingText)
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Log Session Button

    private var logSessionButton: some View {
        Text("Log Session")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.wazaAccent, in: RoundedRectangle(cornerRadius: 14))
            .anyButton(.press) {
                presenter.onLogSessionTapped()
            }
    }

    // MARK: - Activation Card (new user)

    private var activationCard: some View {
        ActivationCardView(
            userName: presenter.userFirstName == "Athlete" ? nil : presenter.userFirstName,
            accentColor: Color.wazaAccent,
            isGymSet: presenter.isGymSet,
            onLogSessionTapped: { presenter.onLogSessionTapped() }
        )
    }

    // MARK: - This Week Section

    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("This Week")

            HStack(spacing: 0) {
                statCell(
                    icon: "flame.fill",
                    value: "\(presenter.streakCount)",
                    label: "day streak"
                )

                Divider().frame(height: 36)

                statCell(
                    icon: "figure.wrestling",
                    value: "\(presenter.sessionsThisWeek)",
                    label: "sessions"
                )

                Divider().frame(height: 36)

                statCell(
                    icon: "clock.fill",
                    value: presenter.hoursThisWeekFormatted,
                    label: "trained"
                )
            }
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func statCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(Color.wazaAccent)
                Text(value)
                    .font(.wazaTitle)
                    .foregroundStyle(Color.wazaAccent)
            }
            Text(label)
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Upcoming Class

    @ViewBuilder
    private var upcomingClassSection: some View {
        if let (schedule, gym) = presenter.nextUpcomingClass {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Next Class")

                UpcomingClassCardView(
                    schedule: schedule,
                    gym: gym,
                    onTap: {
                        presenter.onCheckInTapped(gym: gym, schedule: schedule)
                    }
                )
            }
        }
    }

    // MARK: - Recent Sessions

    @ViewBuilder
    private var recentSessionsSection: some View {
        if !presenter.sessions.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Recent Sessions")

                ForEach(presenter.sessions.prefix(3), id: \.id) { session in
                    SessionRowView(session: session, accentColor: Color.wazaAccent)
                        .anyButton {
                            presenter.onSessionTapped(session)
                        }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var devSettingsButton: some View {
        Image(systemName: "gearshape")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .anyButton {
                presenter.onDevSettingsTapped()
            }
        }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func dashboardView(router: AnyRouter, delegate: DashboardDelegate = DashboardDelegate()) -> some View {
        DashboardView(
            presenter: DashboardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showDashboardView(delegate: DashboardDelegate = DashboardDelegate()) {
        router.showScreen(.push) { router in
            builder.dashboardView(router: router, delegate: delegate)
        }
    }

    func showSessionEntryView(onDismiss: (() -> Void)? = nil) {
        router.showScreen(.sheet, onDismiss: onDismiss) { router in
            builder.sessionEntryView(router: router, delegate: SessionEntryDelegate())
        }
    }

    func showSessionDetailView(session: BJJSessionModel) {
        router.showScreen(.push) { router in
            builder.sessionDetailView(router: router, delegate: SessionDetailDelegate(session: session))
        }
    }

    func showGoalsPlanningView() {
        router.showScreen(.push) { router in
            builder.goalsPlanningView(router: router, delegate: GoalsPlanningDelegate())
        }
    }

    func showPaywallView() {
        router.showScreen(.sheet) { router in
            builder.paywallView(router: router, delegate: PaywallDelegate())
        }
    }

}

// MARK: - Preview

#Preview("Dashboard - Signed In") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.dashboardView(router: router)
    }
}

#Preview("Dashboard - Empty") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.dashboardView(router: router)
    }
}
