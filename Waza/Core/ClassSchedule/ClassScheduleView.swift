import SwiftUI

struct ClassScheduleView: View {
    @State var presenter: ClassSchedulePresenter
    let delegate: ClassSchedulePlanningDelegate

    var body: some View {
        List {
            if presenter.gyms.isEmpty {
                EmptyStateView(
                    icon: "mappin.circle",
                    title: "No Gyms Added",
                    subtitle: "Add your gym to set up recurring class reminders and automatic check-ins.",
                    actionTitle: nil,
                    onAction: nil
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(presenter.gyms, id: \.id) { gym in
                    Section {
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
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Delete") {
                                        presenter.onDeleteScheduleTapped(schedule)
                                    }
                                    .tint(.red)
                                }
                            }
                        }

                        Label("Add Class", systemImage: "plus")
                            .font(.subheadline)
                            .foregroundStyle(Color.wazaAccent)
                            .anyButton {
                                presenter.onAddScheduleTapped(gymId: gym.gymId)
                            }
                    } header: {
                        gymSectionHeader(gym: gym)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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

    // MARK: - Gym Section Header

    private func gymSectionHeader(gym: GymLocationModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(gym.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
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
                .foregroundStyle(Color.wazaAccent)
                .accessibilityLabel("Edit \(gym.name)")
                .anyButton {
                    presenter.onEditGymTapped(gym)
                }
        }
        .textCase(nil)
    }

    // MARK: - Toolbar

    private var addGymButton: some View {
        Button {
            presenter.onAddGymTapped()
        } label: {
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(Color.wazaAccent)
        }
        .accessibilityLabel("Add gym")
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
            builder.addScheduleView(
                router: router,
                delegate: AddScheduleDelegate(gymId: gymId, existingSchedule: existingSchedule, onSaved: onDismiss)
            )
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
