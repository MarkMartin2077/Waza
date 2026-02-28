import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    @State private var isLoaded: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                greetingHeader
                streakHeroCard
                quickStatsRow
                upcomingClassSection
                sessionsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                isLoaded = true
            }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            Text("\(presenter.greeting), \(presenter.userFirstName)")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .fill(presenter.beltAccentColor)
                .frame(width: 12, height: 12)
        }
    }

    // MARK: - Streak Hero Card

    private var streakHeroCard: some View {
        StreakHeroView(
            streakCount: presenter.streakCount > 0 ? presenter.streakCount : nil,
            accentColor: presenter.beltAccentColor
        )
        .padding(.vertical, 24)
        .background(presenter.beltAccentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Quick Stats Row

    private var quickStatsRow: some View {
        HStack(spacing: 0) {
            quickStatCell(
                value: "\(presenter.sessionsThisWeek)",
                label: "sessions",
                sublabel: "this week"
            )

            Divider()
                .frame(height: 48)

            quickStatCell(
                value: presenter.totalTrainingTimeFormatted,
                label: "trained",
                sublabel: "all time"
            )
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func quickStatCell(value: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.wazaStat)
                .foregroundStyle(presenter.beltAccentColor)
            Text(label)
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
            Text(sublabel)
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(presenter.beltAccentColor, lineWidth: 2)
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

            ForEach(Array(presenter.sessions.enumerated()), id: \.element.id) { sessionIndex, session in
                SessionRowView(session: session, accentColor: presenter.beltAccentColor)
                    .anyButton(.press) {
                        presenter.onSessionTapped(session)
                    }
                    .offset(y: isLoaded ? 0 : 20)
                    .opacity(isLoaded ? 1 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.75).delay(Double(sessionIndex) * 0.05),
                        value: isLoaded
                    )
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
