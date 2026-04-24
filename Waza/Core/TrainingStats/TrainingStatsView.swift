import SwiftUI
import SwiftfulUI

struct TrainingStatsView: View {
    @State var presenter: TrainingStatsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !presenter.activeGoals.isEmpty {
                    activeGoalsSection
                        .scaleAppear(delay: 0)
                }
                periodPicker
                    .scaleAppear(delay: 0.05)
                sessionStatsSection
                    .scaleAppear(delay: 0.1)
                typeBreakdownSection
                    .scaleAppear(delay: 0.15)
                beltProgressionCard
                    .scaleAppear(delay: 0.2)
                achievementsCard
                    .scaleAppear(delay: 0.25)
                if presenter.hasMonthlyReport {
                    monthlyReportCard
                        .scaleAppear(delay: 0.3)
                }
            }
            .padding(16)
        }
        .navigationTitle("Progress")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            // Each trailing action gets its own ToolbarItem so iOS 26 renders them
            // as separate liquid-glass capsules instead of one merged bubble.
            if presenter.isAIAvailable {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "apple.intelligence")
                        .font(.headline)
                        .anyButton(.press) {
                            presenter.onAIInsightsTapped()
                        }
                        .accessibilityLabel("AI training insights")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(Color.wazaAccent)
                    .anyButton(.press) {
                        presenter.onManageGoalsTapped()
                    }
                    .accessibilityLabel("Manage goals")
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Goals")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Manage")
                    .font(.caption)
                    .foregroundStyle(Color.wazaAccent)
                    .anyButton {
                        presenter.onManageGoalsTapped()
                    }
            }

            ForEach(Array(presenter.activeGoals.enumerated()), id: \.element.goalId) { index, goal in
                let progress = presenter.computedProgress(for: goal)
                HStack(spacing: 10) {
                    Image(systemName: goal.goalMetric?.iconName ?? goal.goalType.iconName)
                        .foregroundStyle(Color.wazaAccent)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.title)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ProgressView(value: min(progress, 1.0))
                            .tint(Color.wazaAccent)
                            .animation(.easeOut(duration: 0.5), value: progress)
                    }
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                        .frame(width: 36, alignment: .trailing)
                }
                .staggeredAppear(index: index)
            }
        }
        .padding(14)
        .wazaCard()
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(presenter.periodLabels, id: \.self) { label in
                let isSelected = presenter.selectedPeriodLabel == label
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.wazaAccent : Color(.systemGray6))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .anyButton {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            presenter.onPeriodSelected(label: label)
                        }
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var sessionStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                statCard(
                    value: "\(presenter.snapshot.sessionCount)",
                    label: "Sessions",
                    icon: "figure.wrestling"
                )
                statCard(
                    value: String(format: "%.1f", presenter.snapshot.totalHours),
                    label: "Hours",
                    icon: "clock.fill"
                )
                statCard(
                    value: "\(presenter.snapshot.avgDurationMinutes)m",
                    label: "Avg Duration",
                    icon: "timer"
                )
            }
        }
    }

    private var typeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Types")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if presenter.snapshot.typeBreakdown.isEmpty {
                Text("No sessions logged for this period.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(presenter.snapshot.typeBreakdown, id: \.sessionType) { stat in
                        typeRow(stat: stat)
                    }
                }
            }
        }
        .padding(14)
        .wazaCard()
    }

    private func typeRow(stat: TypeStat) -> some View {
        VStack(spacing: 4) {
            HStack {
                Label(stat.sessionType.displayName, systemImage: stat.sessionType.iconName)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(stat.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.wazaAccent)
                        .frame(width: geo.size.width * stat.percentage, height: 6)
                        .animation(.easeOut(duration: 0.5), value: stat.percentage)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Progress Cards

    private var achievementsCard: some View {
        navCard(
            icon: "trophy.fill",
            title: "Achievements",
            subtitle: presenter.achievementsProgressText,
            action: { presenter.onAchievementsTapped() }
        )
    }

    private var monthlyReportCard: some View {
        navCard(
            icon: "doc.text.fill",
            title: "Monthly Report",
            subtitle: "Review last month's training",
            action: { presenter.onMonthlyReportTapped() }
        )
    }

    private var beltProgressionCard: some View {
        let belt = presenter.currentBelt
        let promotions = presenter.beltPromotionCount
        let subtitle = promotions > 0
            ? "\(belt.displayName) • \(promotions) promotion\(promotions == 1 ? "" : "s")"
            : belt.displayName
        return HStack(spacing: 14) {
            Image(systemName: "medal.fill")
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 36, height: 36)
                .background(Color.wazaAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: .wazaCornerSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text("Belt Progression")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaInk900)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.wazaInk500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .wazaCard()
    }

    private func navCard(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 36, height: 36)
                .background(Color.wazaAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: .wazaCornerSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaInk900)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.wazaInk500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.wazaInk400)
        }
        .padding(14)
        .wazaCard()
        .anyButton(.press) { action() }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
            Text(value)
                .font(.wazaTitle)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .wazaCard()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }
}

// MARK: - CoreBuilder Extension

extension CoreBuilder {
    func trainingStatsView(router: AnyRouter) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        let presenter = TrainingStatsPresenter(router: coreRouter, interactor: interactor)
        return TrainingStatsView(presenter: presenter)
    }
}

// MARK: - Previews

#Preview("Progress") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        NavigationStack {
            builder.trainingStatsView(router: router)
        }
    }
}

#Preview("Progress - Empty State") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        NavigationStack {
            builder.trainingStatsView(router: router)
        }
    }
}
