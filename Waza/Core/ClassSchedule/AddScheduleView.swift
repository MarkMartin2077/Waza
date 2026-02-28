import SwiftUI

// MARK: - Add/Edit Schedule Sheet

struct AddScheduleView: View {
    let gymId: String
    let existingSchedule: ClassScheduleModel?
    let onSaved: (() -> Void)?
    let interactor: any ClassScheduleInteractor

    @State private var name: String = ""
    @State private var dayOfWeek: Int = 2
    @State private var startHour: Int = 19
    @State private var startMinute: Int = 0
    @State private var durationMinutes: Int = 60
    @State private var sessionType: SessionType = .gi
    @State private var reminderMinutes: Int = 30
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    private let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Class Name") {
                    TextField("e.g. Monday Gi", text: $name)
                }

                Section("Schedule") {
                    Picker("Day", selection: $dayOfWeek) {
                        ForEach(1...7, id: \.self) { day in
                            Text(dayNames[day - 1]).tag(day)
                        }
                    }

                    Picker("Hour", selection: $startHour) {
                        ForEach(5...23, id: \.self) { hour in
                            let display = hour == 0 ? "12 AM" : hour < 12 ? "\(hour) AM" : hour == 12 ? "12 PM" : "\(hour - 12) PM"
                            Text(display).tag(hour)
                        }
                    }

                    Picker("Minute", selection: $startMinute) {
                        Text("00").tag(0)
                        Text("15").tag(15)
                        Text("30").tag(30)
                        Text("45").tag(45)
                    }

                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 30...180, step: 15)
                }

                Section("Class Type") {
                    Picker("Type", selection: $sessionType) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Reminder") {
                    Picker("Before class", selection: $reminderMinutes) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("60 minutes").tag(60)
                        Text("No reminder").tag(0)
                    }
                    .pickerStyle(.menu)
                }

                if let err = errorMessage {
                    Section {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(existingSchedule == nil ? "Add Class" : "Edit Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty)
                }
            }
            .onAppear { populateFromExisting() }
        }
    }

    private func populateFromExisting() {
        guard let schedule = existingSchedule else { return }
        name = schedule.name
        dayOfWeek = schedule.dayOfWeek
        startHour = schedule.startHour
        startMinute = schedule.startMinute
        durationMinutes = schedule.durationMinutes
        sessionType = schedule.sessionType
        reminderMinutes = schedule.reminderMinutesBefore
    }

    private func save() {
        do {
            if let existing = existingSchedule {
                var updated = existing
                updated.name = name
                updated.dayOfWeek = dayOfWeek
                updated.startHour = startHour
                updated.startMinute = startMinute
                updated.durationMinutes = durationMinutes
                updated.sessionType = sessionType
                updated.reminderMinutesBefore = reminderMinutes
                try interactor.updateSchedule(updated)
            } else {
                let params = AddScheduleParams(
                    gymId: gymId,
                    name: name,
                    dayOfWeek: dayOfWeek,
                    startHour: startHour,
                    startMinute: startMinute,
                    durationMinutes: durationMinutes,
                    sessionType: sessionType,
                    reminderMinutesBefore: reminderMinutes
                )
                try interactor.addSchedule(params)
            }
            onSaved?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func addScheduleView(
        router: AnyRouter,
        gymId: String,
        existingSchedule: ClassScheduleModel?,
        onSaved: (() -> Void)?
    ) -> some View {
        AddScheduleView(
            gymId: gymId,
            existingSchedule: existingSchedule,
            onSaved: onSaved,
            interactor: interactor
        )
    }

}
