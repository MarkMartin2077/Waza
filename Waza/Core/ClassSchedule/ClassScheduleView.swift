import SwiftUI

struct ClassScheduleView: View {
    @State var presenter: ClassSchedulePresenter
    let delegate: ClassSchedulePlanningDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if presenter.gyms.isEmpty {
                    emptyStateView
                } else {
                    ForEach(presenter.gyms, id: \.id) { gym in
                        gymSection(gym: gym)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .navigationTitle("Training Schedule")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                addGymButton
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Gyms Added",
            systemImage: "mappin.circle",
            description: Text("Add your gym to set up recurring class reminders and automatic check-ins.")
        )
        .padding(.top, 32)
    }

    // MARK: - Gym Section

    private func gymSection(gym: GymLocationModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(gym.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let address = gym.address {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Image(systemName: "pencil")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .anyButton {
                        presenter.onEditGymTapped(gym)
                    }
            }
            .padding(.bottom, 4)

            let gymSchedules = presenter.schedulesByGym[gym.gymId] ?? []
            if gymSchedules.isEmpty {
                Text("No classes scheduled")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(gymSchedules, id: \.id) { schedule in
                    ClassScheduleRowView(
                        schedule: schedule,
                        onEdit: { presenter.onEditScheduleTapped(schedule) },
                        onDelete: { presenter.onDeleteScheduleTapped(schedule) }
                    )
                }
            }

            Label("Add Class", systemImage: "plus")
                .font(.subheadline)
                .foregroundStyle(.accent)
                .anyButton {
                    presenter.onAddScheduleTapped(gymId: gym.gymId)
                }
                .padding(.top, 4)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Toolbar

    private var addGymButton: some View {
        Image(systemName: "plus")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onAddGymTapped()
            }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func classScheduleView(router: AnyRouter, delegate: ClassSchedulePlanningDelegate = ClassSchedulePlanningDelegate()) -> some View {
        ClassScheduleView(
            presenter: ClassSchedulePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showClassScheduleView() {
        router.showScreen(.push) { router in
            builder.classScheduleView(router: router)
        }
    }

    func showAddScheduleSheet(gymId: String, existingSchedule: ClassScheduleModel?, onDismiss: (() -> Void)? = nil) {
        router.showScreen(.sheet) { router in
            builder.addScheduleView(router: router, gymId: gymId, existingSchedule: existingSchedule, onSaved: onDismiss)
        }
    }

}

// MARK: - Preview

#Preview("Class Schedule") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.classScheduleView(router: router)
    }
}
