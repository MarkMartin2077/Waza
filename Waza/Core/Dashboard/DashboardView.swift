import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statStrip
                upcomingClassSection
                sessionsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .navigationTitle("Waza")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                devSettingsButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                aiInsightsButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                addSessionButton
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Stat Strip

    private var statStrip: some View {
        HStack(spacing: 0) {
            Image(systemName: "flame.fill")
                .foregroundStyle(presenter.streakCount > 0 ? .orange : .secondary)
            Text(presenter.streakCount > 0 ? " \(presenter.streakCount) day streak" : " No streak")
                .foregroundStyle(presenter.streakCount > 0 ? .primary : .secondary)
            Text("  ·  ")
                .foregroundStyle(.secondary)
            Text("\(presenter.sessionsThisWeek) this week")
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Upcoming Class

    @ViewBuilder
    private var upcomingClassSection: some View {
        if let (schedule, gym) = presenter.nextUpcomingClass {
            UpcomingClassCardView(
                schedule: schedule,
                gym: gym,
                onTap: {
                    presenter.onCheckInTapped(gym: gym, schedule: schedule)
                }
            )
        }
    }

    // MARK: - Sessions

    @ViewBuilder
    private var sessionsSection: some View {
        if presenter.sessions.isEmpty {
            ContentUnavailableView(
                "No Sessions Yet",
                systemImage: "figure.martial.arts",
                description: Text("Tap + to log your first training session.")
            )
            .padding(.top, 32)
        } else {
            sessionsList
        }
    }

    private var sessionsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(presenter.sessions, id: \.id) { session in
                SessionRowView(session: session)
                    .anyButton(.press) {
                        presenter.onSessionTapped(session)
                    }
            }
        }
    }

    // MARK: - Toolbar Buttons

    private var aiInsightsButton: some View {
        Image(systemName: "apple.intelligence")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onAIInsightsTapped()
            }
    }

    private var addSessionButton: some View {
        Image(systemName: "plus")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onLogSessionTapped()
            }
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
