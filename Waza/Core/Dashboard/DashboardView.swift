import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: Greeting
                greetingHeader
                    .scaleAppear(delay: 0)

                if presenter.showMonthlyReportBanner {
                    monthlyReportBanner
                        .padding(.top, 16)
                        .scaleAppear(delay: 0.02)
                }

                // MARK: XP + Belt strip
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
                    .padding(.top, 20)
                    .scaleAppear(delay: 0.03)
                }

                // MARK: Streak hero
                if !presenter.isNewUser {
                    streakHeroSection
                        .padding(.top, 24)
                        .scaleAppear(delay: 0.04)
                }

                // MARK: Weekly practice grid
                if !presenter.isNewUser {
                    weeklyPracticeGrid
                        .padding(.top, 20)
                        .scaleAppear(delay: 0.05)
                }

                // MARK: Weekly challenges
                if !presenter.isNewUser, !presenter.challenges.isEmpty {
                    if presenter.showChallengesTip {
                        challengesTip
                            .padding(.top, 20)
                            .scaleAppear(delay: 0.06)
                    }
                    WeeklyChallengesCardView(
                        challenges: presenter.challenges,
                        completedCount: presenter.completedChallengeCount,
                        accentColor: Color.wazaAccent
                    )
                    .padding(.top, 20)
                    .scaleAppear(delay: 0.065)
                }

                // MARK: Technique journal
                if !presenter.isNewUser, presenter.sessionStats.totalSessions >= 3 {
                    techniqueJournalCard
                        .padding(.top, 20)
                        .scaleAppear(delay: 0.07)
                }

                // MARK: Log session CTA
                logSessionButton
                    .padding(.top, 24)
                    .scaleAppear(delay: 0.08)

                // MARK: New user / This week
                if presenter.isNewUser {
                    activationCard
                        .padding(.top, 20)
                        .scaleAppear(delay: 0.1)
                }

                // MARK: Upcoming class
                upcomingClassSection
                    .padding(.top, 24)
                    .scaleAppear(delay: 0.12)

                // MARK: Recent sessions
                recentSessionsSection
                    .padding(.top, 24)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
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
        VStack(alignment: .leading, spacing: 2) {
            Text("\(presenter.greeting),")
                .font(.wazaDisplayLarge)
                .italic()
            if presenter.userFirstName != "Athlete" && !presenter.userFirstName.isEmpty {
                Text("\(presenter.userFirstName).")
                    .font(.wazaDisplayLarge)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Log Session Button

    private var logSessionButton: some View {
        VStack(spacing: 0) {
            // Primary CTA
            HStack {
                HStack(spacing: 12) {
                    Text("技")
                        .font(.system(size: 22))
                    Text("Record today's session")
                        .font(.wazaBody)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("+ XP")
                    .font(.wazaLabel)
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .opacity(0.75)
            }
            .foregroundStyle(Color.wazaPaperHi)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(Color.wazaAccent)
            )
            .anyButton(.press) {
                presenter.onLogSessionTapped()
            }
            .accessibilityLabel("Log a new training session")
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

    // MARK: - Streak Hero

    private var streakHeroSection: some View {
        VStack(spacing: 0) {
            Divider().background(Color.wazaInk300)

            VStack(spacing: 16) {
                // Big streak number
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT STREAK")
                        .wazaLabelStyle()
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(presenter.streakCount)")
                            .font(.wazaHero)
                            .foregroundStyle(Color.wazaAccent)
                            .contentTransition(.numericText())
                        Text("days on the mat")
                            .font(.wazaDisplaySmall)
                            .italic()
                            .foregroundStyle(Color.wazaInk600)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().background(Color.wazaInk300)

                // Streak sub-stats
                HStack(spacing: 16) {
                    streakSubStat(label: "FREEZES", value: String(format: "%02d", presenter.freezesAvailable))
                    streakSubStat(label: "SESSIONS", value: "\(presenter.sessionsThisWeek)")
                    streakSubStat(label: "TRAINED", value: presenter.hoursThisWeekFormatted)
                }
            }
            .padding(.vertical, 20)
        }
    }

    private func streakSubStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .wazaLabelStyle()
            Text(value)
                .font(.wazaNumSmall)
                .foregroundStyle(Color.wazaInk900)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Weekly Practice Grid

    private var weeklyPracticeGrid: some View {
        VStack(spacing: 0) {
            Divider().background(Color.wazaInk300)

            VStack(spacing: 14) {
                HStack {
                    Text("THIS WEEK'S PRACTICE")
                        .wazaLabelStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("MON–SUN")
                        .wazaLabelStyle()
                }

                HStack(spacing: 6) {
                    ForEach(Array(presenter.weeklyPracticeGrid.enumerated()), id: \.offset) { _, day in
                        weekDayCell(day)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }

    private func weekDayCell(_ day: DashboardPresenter.WeekDay) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(day.isTrained ? Color.wazaAccent : Color.wazaPaperHi)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(day.isToday ? Color.wazaInk900 : Color.wazaInk300, lineWidth: day.isToday ? 1.5 : 0.5)
            )
            .overlay(
                Group {
                    if let session = day.session {
                        Text(session.sessionType.kanji)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.wazaPaperHi)
                    } else {
                        Text(day.label)
                            .font(.wazaLabel)
                            .foregroundStyle(day.isToday ? Color.wazaInk900 : Color.wazaInk400)
                    }
                }
            )
            .aspectRatio(1, contentMode: .fit)
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
