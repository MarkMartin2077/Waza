import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                streakIndicator
                upcomingClassSection
                weeklyRingSection
                recentSessionsContent
                if !presenter.activeGoals.isEmpty {
                    activeGoalsSection
                }
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

    // MARK: - Weekly Ring

    private var weeklyRingSection: some View {
        WeeklyAttendanceRingView(
            current: presenter.weeklyAttendanceCount,
            target: presenter.weeklyAttendanceTarget
        )
        .anyButton(.press) {
            presenter.onScheduleTapped()
        }
    }

    // MARK: - Streak Indicator

    private var streakIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(presenter.streakCount > 0 ? .orange : .secondary)
            Text(presenter.streakCount > 0 ? "\(presenter.streakCount) day streak" : "No active streak")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(presenter.streakCount > 0 ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Recent Sessions

    @ViewBuilder
    private var recentSessionsContent: some View {
        if presenter.recentSessions.isEmpty {
            ContentUnavailableView(
                "No Sessions Yet",
                systemImage: "figure.martial.arts",
                description: Text("Tap + to log your first training session.")
            )
            .padding(.top, 32)
        } else {
            recentSessionsSection
        }
    }

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(presenter.recentSessions, id: \.id) { session in
                SessionRowView(session: session)
                    .anyButton(.press) {
                        presenter.onSessionTapped(session)
                    }
            }
        }
    }

    // MARK: - Active Goals

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Active Goals")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("See all")
                    .font(.caption)
                    .foregroundStyle(.accent)
                    .anyButton {
                        presenter.onGoalsTapped()
                    }
            }

            ForEach(presenter.activeGoals, id: \.id) { goal in
                GoalRowView(goal: goal)
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

// MARK: - Session Row Component

private struct SessionRowView: View {
    let session: BJJSessionModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.iconName)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 40, height: 40)
                .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(session.sessionType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 6) {
                    Text(session.dateFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(session.durationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Goal Row Component

private struct GoalRowView: View {
    let goal: TrainingGoalModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.goalType.iconName)
                    .font(.caption)
                    .foregroundStyle(.accent)
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(goal.progressPercentage)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: goal.progress)
                .tint(.accent)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
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
