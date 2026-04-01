import SwiftUI
import SwiftfulUI

struct TrainingStatsView: View {
    @State var presenter: TrainingStatsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !presenter.activeGoals.isEmpty {
                    activeGoalsSection
                }
                periodPicker
                sessionStatsSection
                typeBreakdownSection
            }
            .padding(16)
        }
        .navigationTitle("Progress")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    if presenter.isAIAvailable {
                        Image(systemName: "apple.intelligence")
                            .font(.headline)
                            .anyButton {
                                presenter.onAIInsightsTapped()
                            }
                    }
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(Color.wazaAccent)
                        .anyButton {
                            presenter.onManageGoalsTapped()
                        }
                }
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

            ForEach(presenter.activeGoals, id: \.goalId) { goal in
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
                    }
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(presenter.periodLabels, id: \.self) { label in
                Text(label)
                    .font(.subheadline)
                    .fontWeight(presenter.selectedPeriodLabel == label ? .semibold : .regular)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(presenter.selectedPeriodLabel == label ? Color.wazaAccent : Color(.systemGray6))
                    .foregroundStyle(presenter.selectedPeriodLabel == label ? .white : .primary)
                    .anyButton {
                        presenter.onPeriodSelected(label: label)
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
                }
            }
            .frame(height: 6)
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
            Text(value)
                .font(.wazaTitle)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
