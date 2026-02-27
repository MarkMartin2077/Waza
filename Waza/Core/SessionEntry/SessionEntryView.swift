import SwiftUI

struct SessionEntryView: View {
    @State var presenter: SessionEntryPresenter
    let delegate: SessionEntryDelegate

    var body: some View {
        NavigationStack {
            Form {
                dateSection
                typeAndDurationSection
                locationSection
                focusAreasSection
                reflectionSection
                moodSection
                statsSection
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presenter.onCancelPressed()
                    }
                    .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Group {
                        if presenter.isLoading {
                            ProgressView()
                        } else {
                            Button("Save") {
                                presenter.onSavePressed()
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
            }
            .alert("Error", isPresented: Binding(
                get: { presenter.errorMessage != nil },
                set: { if !$0 { presenter.errorMessage = nil } }
            )) {
                Button("OK") { presenter.errorMessage = nil }
            } message: {
                Text(presenter.errorMessage ?? "")
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Sections

    private var dateSection: some View {
        Section("Date & Time") {
            DatePicker("Date", selection: $presenter.date, displayedComponents: [.date, .hourAndMinute])
        }
    }

    private var typeAndDurationSection: some View {
        Section("Session") {
            Picker("Type", selection: $presenter.sessionType) {
                ForEach(SessionType.allCases, id: \.self) { type in
                    Label(type.displayName, systemImage: type.iconName).tag(type)
                }
            }

            HStack {
                Text("Duration")
                Spacer()
                Text(presenter.durationText)
                    .foregroundStyle(.secondary)
                Stepper("", value: $presenter.durationMinutes, in: 15...300, step: 15)
                    .labelsHidden()
            }
        }
    }

    private var locationSection: some View {
        Section("Location (Optional)") {
            TextField("Academy", text: $presenter.academy)
            TextField("Instructor", text: $presenter.instructor)
        }
    }

    private var focusAreasSection: some View {
        Section {
            if presenter.selectedFocusAreas.isEmpty {
                Text("Tap to add focus areas")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presenter.selectedFocusAreas, id: \.self) { area in
                            Text(area)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.accent.opacity(0.15), in: Capsule())
                                .foregroundStyle(.accent)
                        }
                    }
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(presenter.availableFocusAreas, id: \.self) { area in
                    let isSelected = presenter.selectedFocusAreas.contains(area)
                    Text(area)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? .accent : .secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .anyButton(.press) {
                            presenter.toggleFocusArea(area)
                        }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Focus Areas")
        }
    }

    private var reflectionSection: some View {
        Section("Reflection (Optional)") {
            TextField("General notes", text: $presenter.notes, axis: .vertical)
                .lineLimit(3...6)
            TextField("What worked well?", text: $presenter.whatWorkedWell, axis: .vertical)
                .lineLimit(2...4)
            TextField("Needs improvement", text: $presenter.needsImprovement, axis: .vertical)
                .lineLimit(2...4)
            TextField("Key insights", text: $presenter.keyInsights, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var moodSection: some View {
        Section {
            Toggle("Track mood", isOn: $presenter.showMoodSection)
            if presenter.showMoodSection {
                moodPicker(label: "Before training", value: $presenter.preSessionMood)
                moodPicker(label: "After training", value: $presenter.postSessionMood)
            }
        } header: {
            Text("Mood")
        }
    }

    private func moodPicker(label: String, value: Binding<Int>) -> some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: value) {
                ForEach(1...5, id: \.self) { rating in
                    Text(moodEmoji(rating)).tag(rating)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 160)
        }
    }

    private func moodEmoji(_ value: Int) -> String {
        switch value {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }

    private var statsSection: some View {
        Section("Rounds") {
            Stepper("Rounds: \(presenter.roundsCount)", value: $presenter.roundsCount, in: 0...20)
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func sessionEntryView(router: AnyRouter, delegate: SessionEntryDelegate = SessionEntryDelegate()) -> some View {
        SessionEntryView(
            presenter: SessionEntryPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

// MARK: - Preview

#Preview("Session Entry") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.sessionEntryView(router: router)
    }
}
