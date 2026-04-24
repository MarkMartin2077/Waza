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

                // MARK: Reorganization nudge (one-time, below primary content)
                if presenter.showReorganizationNudge {
                    ReorganizationNudgeView(
                        onDismiss: { presenter.onDismissReorganizationNudge() }
                    )
                    .padding(.top, 20)
                    .scaleAppear(delay: 0.055)
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

                Color.clear.frame(height: 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        let hasName = presenter.userFirstName != "Athlete" && !presenter.userFirstName.isEmpty
        let trimmed = presenter.greeting.trimmingCharacters(in: .whitespaces)
        let endsInPunctuation = trimmed.last.map { "?!.".contains($0) } ?? false
        // If greeting ends in ? or !, keep it as its own line; otherwise add a comma before the name.
        let greetingText = hasName && !endsInPunctuation ? "\(trimmed)," : trimmed

        return VStack(alignment: .leading, spacing: 2) {
            Text(greetingText)
                .font(.wazaDisplayLarge)
                .italic()
            if hasName {
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
                    streakSubStat(label: "FREEZES", value: "\(presenter.freezesAvailable)")
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
        VStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 2)
                .fill(day.isTrained ? Color.wazaAccent : Color.wazaPaperHi)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(day.isToday ? Color.wazaInk900 : Color.wazaInk300, lineWidth: day.isToday ? 1.5 : 0.5)
                )
                .overlay(
                    Group {
                        if let session = day.latestSession {
                            VStack(spacing: 0) {
                                Text(session.sessionType.kanji)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.wazaPaperHi)
                                if day.sessions.count > 1 {
                                    Text("×\(day.sessions.count)")
                                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color.wazaPaperHi.opacity(0.7))
                                }
                            }
                        } else {
                            Text(day.label)
                                .font(.wazaLabel)
                                .foregroundStyle(day.isToday ? Color.wazaInk900 : Color.wazaInk400)
                        }
                    }
                )
                .aspectRatio(1, contentMode: .fit)

            // Short label so users know what the kanji means
            if let session = day.latestSession {
                Text(session.sessionType.shortLabel)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.wazaInk500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text(" ")
                    .font(.system(size: 8))
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .wazaLabelStyle()
            .frame(maxWidth: .infinity, alignment: .leading)
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
