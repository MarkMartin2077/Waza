import SwiftUI

struct DashboardView: View {
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                greetingHeader
                streakHeroCard
                if presenter.isNewUser {
                    activationCard
                } else {
                    quickStatsRow
                }
                upcomingClassSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                devSettingsButton
            }
        }
        .onAppear {
            presenter.onViewAppear()
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

    // MARK: - Activation Card (new user)

    private var activationCard: some View {
        ActivationCardView(
            userName: presenter.userFirstName == "Athlete" ? nil : presenter.userFirstName,
            accentColor: presenter.beltAccentColor,
            isBeltSet: presenter.isBeltSet,
            isGymSet: presenter.isGymSet,
            onLogSessionTapped: { presenter.onLogSessionTapped() },
            onSetBeltTapped: { presenter.onSetBeltTapped() }
        )
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

    // MARK: - Toolbar Buttons

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
