import SwiftUI

struct GoalsPlanningView: View {
    @State var presenter: GoalsPlanningPresenter
    let delegate: GoalsPlanningDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                beltProgressCard
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddGoalTapped()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $presenter.showAddGoalSheet) {
            addGoalSheet
        }
        .alert("Error", isPresented: Binding(
            get: { presenter.errorMessage != nil },
            set: { if !$0 { presenter.errorMessage = nil } }
        )) {
            Button("OK") { presenter.errorMessage = nil }
        } message: {
            Text(presenter.errorMessage ?? "")
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Belt Progress Card

    private var beltProgressCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Belt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(presenter.currentBelt.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(presenter.nextBeltText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .stroke(Color(hex: presenter.currentBelt.colorHex), lineWidth: 6)
                .frame(width: 52, height: 52)
                .overlay {
                    Text(String(presenter.currentBelt.displayName.prefix(1)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: presenter.currentBelt.colorHex))
                }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
            Button {
                presenter.showCompletedGoals.toggle()
            } label: {
                HStack {
                    Text("Completed (\(presenter.completedGoals.count))")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: presenter.showCompletedGoals ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Active Goals")
                .font(.headline)
            Text("Set a goal to track your BJJ progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("Add Goal")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.accent, in: Capsule())
                .anyButton(.press) {
                    presenter.onAddGoalTapped()
                }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Add Goal Sheet

    private var addGoalSheet: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Goal title", text: $presenter.newGoalTitle)
                    TextField("Description (optional)", text: $presenter.newGoalDescription, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Type") {
                    Picker("Type", selection: $presenter.newGoalType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.iconName).tag(type)
                        }
                    }
                }

                Section("Deadline") {
                    Toggle("Set deadline", isOn: $presenter.newGoalHasDeadline)
                    if presenter.newGoalHasDeadline {
                        DatePicker("Deadline", selection: $presenter.newGoalDeadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presenter.onCancelAddGoal()
                    }
                    .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        presenter.onSaveNewGoal()
                    }
                    .fontWeight(.semibold)
                    .disabled(presenter.newGoalTitle.isEmpty)
                }
            }
        }
    }
}

// MARK: - Goal Card Component

private struct GoalCardView: View {
    let goal: TrainingGoalModel
    let onUpdateProgress: (Double) -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: goal.goalType.iconName)
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .frame(width: 28, height: 28)
                    .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

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
                    Button("Mark Complete") { onComplete() }
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
                ProgressView(value: goal.progress)
                    .tint(.accent)
                Text("\(goal.progressPercentage)%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, alignment: .trailing)
            }

            if let days = goal.daysUntilDeadline {
                Text(days > 0 ? "\(days) days left" : "Overdue")
                    .font(.caption2)
                    .foregroundStyle(days > 7 ? Color.secondary : Color.red)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
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
