import SwiftUI

struct GoalsPlanningView: View {
    @State var presenter: GoalsPlanningPresenter
    let delegate: GoalsPlanningDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if presenter.activeGoals.isEmpty {
                    emptyStateView
                } else {
                    activeGoalsSection
                }
                if !presenter.completedGoals.isEmpty {
                    completedSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationTitle("Goals")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .accessibilityLabel("Add goal")
                    .anyButton {
                        presenter.onAddGoalTapped()
                    }
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Active Goals

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Goals")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(presenter.activeGoals, id: \.id) { goal in
                GoalCardView(
                    goal: goal,
                    progressOverride: presenter.computedProgress(for: goal),
                    progressLabel: presenter.progressLabel(for: goal),
                    onUpdateProgress: { newProgress in
                        presenter.onUpdateProgress(goal, newProgress: newProgress)
                    },
                    onComplete: {
                        presenter.onCompleteGoal(goal)
                    },
                    onDelete: {
                        presenter.onDeleteGoal(goal)
                    }
                )
            }
        }
    }

    // MARK: - Completed Goals

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Completed (\(presenter.completedGoals.count))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: presenter.showCompletedGoals ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .anyButton(.plain) {
                presenter.showCompletedGoals.toggle()
            }

            if presenter.showCompletedGoals {
                ForEach(presenter.completedGoals, id: \.id) { goal in
                    completedGoalRow(goal: goal)
                }
            }
        }
    }

    private func completedGoalRow(goal: TrainingGoalModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(goal.title)
                .font(.subheadline)
                .strikethrough(true, color: .secondary)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .wazaCard(cornerRadius: .wazaCornerSmall)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        EmptyStateView(
            icon: "target",
            title: "No Active Goals",
            subtitle: "Set a goal to track your BJJ progress",
            actionTitle: "Add Goal",
            onAction: { presenter.onAddGoalTapped() }
        )
    }

}

// MARK: - Add Goal Sheet

struct AddGoalSheetView: View {
    let focusAreaOptions: [String]
    let onSave: (GoalMetric, Int, String?) -> Void
    let onCancel: () -> Void

    @State private var selectedMetric: GoalMetric = .sessionsPerWeek
    @State private var target: Int = 3
    @State private var selectedFocusArea: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    metricPickerSection
                    targetSection
                    if selectedMetric == .focusAreaSessions {
                        focusAreaSection
                    }
                }
                .padding(16)
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { onCancel() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let focus: String? = selectedMetric == .focusAreaSessions && !selectedFocusArea.isEmpty ? selectedFocusArea : nil
                        onSave(selectedMetric, target, focus)
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedMetric == .focusAreaSessions && selectedFocusArea.isEmpty)
                }
            }
        }
    }

    private var metricPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What do you want to track?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(GoalMetric.allCases, id: \.self) { metric in
                    let isSelected = selectedMetric == metric
                    HStack(spacing: 12) {
                        Image(systemName: metric.iconName)
                            .font(.title3)
                            .foregroundStyle(isSelected ? .white : Color.wazaAccent)
                            .frame(width: 40, height: 40)
                            .background(
                                isSelected ? Color.wazaAccent : Color.wazaAccent.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 12)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(metric.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(metric.resetLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.wazaAccent)
                        }
                    }
                    .padding(12)
                    .background(
                        isSelected ? Color.wazaAccent.opacity(0.08) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.wazaAccent : Color(.systemGray4), lineWidth: 1)
                    )
                    .anyButton {
                        selectedMetric = metric
                    }
                }
            }
        }
    }

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set your target")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.wazaAccent)
                    .anyButton {
                        if target > 1 { target -= 1 }
                    }

                VStack(spacing: 2) {
                    Text("\(target)")
                        .font(.system(size: 36, weight: .light, design: .monospaced))
                        .foregroundStyle(Color.wazaAccent)
                    Text(selectedMetric.unitLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: 80)

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.wazaAccent)
                    .anyButton {
                        if target < selectedMetric.maxTarget { target += 1 }
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .wazaCard()
        }
    }

    private var focusAreaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Which focus area?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !focusAreaOptions.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(focusAreaOptions, id: \.self) { area in
                        let isSelected = selectedFocusArea == area
                        Text(area)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                isSelected ? Color.wazaAccent : Color(.systemGray6),
                                in: Capsule()
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                            .anyButton(.press) {
                                selectedFocusArea = area
                            }
                    }
                }
            }

            TextField("Or type a focus area...", text: $selectedFocusArea)
                .font(.subheadline)
                .padding(12)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Goal Card Component

private struct GoalCardView: View {
    let goal: TrainingGoalModel
    var progressOverride: Double?
    var progressLabel: String?
    let onUpdateProgress: (Double) -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    private var displayProgress: Double {
        progressOverride ?? goal.progress
    }

    private var displayPercentage: Int {
        Int(displayProgress * 100)
    }

    private var iconName: String {
        goal.goalMetric?.iconName ?? goal.goalType.iconName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .font(.subheadline)
                    .foregroundStyle(Color.wazaAccent)
                    .frame(width: 28, height: 28)
                    .background(Color.wazaAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let desc = goal.goalDescription {
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Menu {
                    if !goal.isMetricGoal {
                        Button("Mark Complete") { onComplete() }
                    }
                    Divider()
                    Button("Delete", role: .destructive) { onDelete() }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
            }

            HStack(spacing: 8) {
                ProgressView(value: min(displayProgress, 1.0))
                    .tint(Color.wazaAccent)

                if let progressLabel {
                    Text(progressLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(displayPercentage)%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }

            if let metric = goal.goalMetric {
                Text(metric.resetLabel)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else if let days = goal.daysUntilDeadline {
                Text(days > 0 ? "\(days) days left" : "Overdue")
                    .font(.caption2)
                    .foregroundStyle(days > 7 ? Color.secondary : Color.red)
            }
        }
        .padding(14)
        .wazaCard()
    }
}

// MARK: - CoreRouter Extension

extension CoreRouter {

    func showAddGoalSheet(focusAreaOptions: [String], onSave: @escaping (GoalMetric, Int, String?) -> Void) {
        router.showScreen(.sheet) { _ in
            AddGoalSheetView(
                focusAreaOptions: focusAreaOptions,
                onSave: onSave,
                onCancel: { self.router.dismissScreen() }
            )
        }
    }

}

// MARK: - Builder Extension

extension CoreBuilder {

    func goalsPlanningView(router: AnyRouter, delegate: GoalsPlanningDelegate = GoalsPlanningDelegate()) -> some View {
        GoalsPlanningView(
            presenter: GoalsPlanningPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

// MARK: - Preview

#Preview("Goals - With Data") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.goalsPlanningView(router: router)
    }
}

#Preview("Goals - Empty") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.goalsPlanningView(router: router)
    }
}

#Preview("Goals - Navigation Stack") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        NavigationStack {
            builder.goalsPlanningView(router: router)
        }
    }
}
