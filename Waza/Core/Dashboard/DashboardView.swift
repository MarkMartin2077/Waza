import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    statsRow
                    if !presenter.recentSessions.isEmpty {
                        recentSessionsSection
                    }
                    if !presenter.activeGoals.isEmpty {
                        activeGoalsSection
                    }
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            logSessionButton
        }
        .navigationTitle("Waza")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                devSettingsButton
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            beltCard
            streakCard
        }
    }

    private var beltCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Belt")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(presenter.beltDisplayName)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(presenter.totalXP) XP")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Streak")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(presenter.streakCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundStyle(presenter.streakCount > 0 ? .orange : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCell(
                value: "\(presenter.sessionStats.totalSessions)",
                label: "Total Sessions"
            )
            statCell(
                value: "\(presenter.sessionStats.thisWeekSessions)",
                label: "This Week"
            )
            statCell(
                value: String(format: "%.0f", presenter.sessionStats.totalTrainingHours),
                label: "Hrs Trained"
            )
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Recent Sessions

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

    // MARK: - Log Session FAB

    private var logSessionButton: some View {
        Text("Log Session")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.accent, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .anyButton(.press) {
                presenter.onLogSessionTapped()
            }
    }

    private var devSettingsButton: some View {
        Image(systemName: "gearshape")
            .font(.headline)
            .foregroundStyle(.accent)
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
