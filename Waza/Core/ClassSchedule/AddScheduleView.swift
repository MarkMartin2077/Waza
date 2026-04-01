import SwiftUI

struct AddScheduleView: View {
    @State var presenter: AddSchedulePresenter

    var body: some View {
        NavigationStack {
            Form {
                Section("Class Name") {
                    TextField("e.g. Monday Gi", text: $presenter.name)
                }

                Section("Schedule") {
                    Picker("Day", selection: $presenter.dayOfWeek) {
                        ForEach(1...7, id: \.self) { day in
                            Text(presenter.dayNames[day - 1]).tag(day)
                        }
                    }

                    Picker("Hour", selection: $presenter.startHour) {
                        ForEach(5...23, id: \.self) { hour in
                            let display = hour == 0 ? "12 AM" : hour < 12 ? "\(hour) AM" : hour == 12 ? "12 PM" : "\(hour - 12) PM"
                            Text(display).tag(hour)
                        }
                    }

                    Picker("Minute", selection: $presenter.startMinute) {
                        Text("00").tag(0)
                        Text("15").tag(15)
                        Text("30").tag(30)
                        Text("45").tag(45)
                    }

                    Stepper("Duration: \(presenter.durationMinutes) min", value: $presenter.durationMinutes, in: 30...180, step: 15)
                }

                Section("Class Type") {
                    Picker("Type", selection: $presenter.sessionType) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Reminder") {
                    Picker("Before class", selection: $presenter.reminderMinutes) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("60 minutes").tag(60)
                        Text("No reminder").tag(0)
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle(presenter.delegate.existingSchedule == nil ? "Add Class" : "Edit Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Cancel")
                        .foregroundStyle(.secondary)
                        .anyButton {
                            presenter.onCancelTapped()
                        }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .anyButton {
                            presenter.onSaveTapped()
                        }
                        .disabled(presenter.isSaveDisabled)
                }
            }
            .onAppear {
                presenter.onViewAppear()
            }
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func addScheduleView(router: AnyRouter, delegate: AddScheduleDelegate) -> some View {
        AddScheduleView(
            presenter: AddSchedulePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

// MARK: - Preview

#Preview("Add Schedule") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.addScheduleView(router: router, delegate: AddScheduleDelegate(gymId: "gym-1"))
    }
}

#Preview("Edit Schedule") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let existing = ClassScheduleModel.mock

    return RouterView { router in
        builder.addScheduleView(router: router, delegate: AddScheduleDelegate(gymId: "gym-1", existingSchedule: existing))
    }
}
