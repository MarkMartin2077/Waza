import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                greetingHeader
                    .scaleAppear(delay: 0)

                if presenter.showMonthlyReportBanner {
                    monthlyReportBanner
                        .scaleAppear(delay: 0.02)
                }

                if !presenter.isNewUser {
                    DashboardXPBadgeView(
                        levelInfo: presenter.xpLevelInfo,
                        fireRoundExpiresAt: presenter.fireRoundExpiresAt,
                        streakTier: presenter.streakTier,
                        streakCount: presenter.streakCount,
                        isStreakAtRisk: presenter.isStreakAtRisk,
                        freezesAvailable: presenter.freezesAvailable,
                        perfectWeekActive: presenter.perfectWeekActive,
                        onUseFreezePressed: presenter.freezesAvailable > 0
                            ? { presenter.onUseStreakFreezePressed() }
                            : nil,
                        accentColor: Color.wazaAccent
                    )
                    .scaleAppear(delay: 0.03)
                }

                if !presenter.isNewUser, !presenter.challenges.isEmpty {
                    if presenter.showChallengesTip {
                        challengesTip
                            .scaleAppear(delay: 0.045)
                    }
                    WeeklyChallengesCardView(
                        challenges: presenter.challenges,
                        completedCount: presenter.completedChallengeCount,
                        accentColor: Color.wazaAccent
                    )
                    .scaleAppear(delay: 0.05)
                }

                if !presenter.isNewUser, presenter.sessionStats.totalSessions >= 3 {
                    techniqueJournalCard
                        .scaleAppear(delay: 0.06)
                }

                logSessionButton
                    .scaleAppear(delay: 0.07)

                if presenter.isNewUser {
                    activationCard
                        .scaleAppear(delay: 0.1)
                } else {
                    thisWeekSection
                        .scaleAppear(delay: 0.1)
                }

                upcomingClassSection
                    .scaleAppear(delay: 0.15)
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
            .font(.wazaDisplayLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Log Session Button

    private var logSessionButton: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
            Text("Log Session")
                .font(.system(.title3, weight: .semibold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.wazaAccent)
                .shadow(color: Color.wazaAccent.opacity(0.35), radius: 12, y: 6)
        )
        .anyButton(.press) {
            presenter.onLogSessionTapped()
        }
        .accessibilityLabel("Log a new training session")
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
            .wazaCard()
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
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
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

                ForEach(Array(presenter.sessions.prefix(3).enumerated()), id: \.element.id) { index, session in
                    SessionRowView(session: session, accentColor: Color.wazaAccent)
                        .staggeredAppear(index: index)
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
            .wazaLabelStyle()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var devSettingsButton: some View {
        Button {
            presenter.onDevSettingsTapped()
        } label: {
            Image(systemName: "gearshape")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Developer settings")
    }

    // MARK: - Onboarding Tips & Discovery

    private var challengesTip: some View {
        // Intentionally lightweight — a thin outlined strip so it reads as a nudge,
        // not as a primary card competing with the Weekly Challenges surface below.
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundStyle(Color.wazaAccent)
            Text("Complete weekly challenges to earn XP and streak freezes")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "xmark")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(4)
                .contentShape(Rectangle())
                .accessibilityLabel("Dismiss tip")
                .anyButton {
                    presenter.onDismissChallengesTip()
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .strokeBorder(Color.wazaAccent.opacity(0.25), lineWidth: 1)
        )
    }

    private var monthlyReportBanner: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.subheadline)
                .foregroundStyle(Color.wazaAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Your monthly report is ready")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Stats, trends, and highlights from last month.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "xmark")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(6)
                .contentShape(Rectangle())
                .accessibilityLabel("Dismiss banner")
                .anyButton {
                    presenter.onDismissMonthlyReportBanner()
                }
        }
        .padding(12)
        .wazaCard(cornerRadius: .wazaCornerSmall)
        .contentShape(Rectangle())
        .anyButton(.press) {
            presenter.onMonthlyReportBannerTapped()
        }
    }

    private var techniqueJournalCard: some View {
        HStack(alignment: .center, spacing: 12) {
            // Rounded-rectangle icon container matches the pattern used on Profile's
            // navigation rows (Achievements, Monthly Report) for consistency.
            Image(systemName: "book.fill")
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 44, height: 44)
                .background(Color.wazaAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: .wazaCornerSmall))
            VStack(alignment: .leading, spacing: 2) {
                Text("Technique Journal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(techniqueJournalSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .wazaCard()
        .contentShape(Rectangle())
        .anyButton(.press) {
            presenter.onTechniqueJournalCardTapped()
        }
    }

    private var techniqueJournalSubtitle: String {
        let count = presenter.techniqueCount
        if count == 0 {
            return "Track what you're learning and drilling"
        }
        return "\(count) technique\(count == 1 ? "" : "s") in your library"
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
