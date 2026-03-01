import SwiftUI

struct SessionEntryView: View {
    @State var presenter: SessionEntryPresenter
    let delegate: SessionEntryDelegate

    @State private var locationExpanded = false
    @State private var reflectionExpanded = false
    @State private var statsExpanded = false

    private let moodEmojis = ["😞", "😕", "😐", "🙂", "😄"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    typeCard
                    dateAndDurationCard
                    locationCard
                    reflectionCard
                    statsCard
                    saveButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { presenter.onCancelPressed() }
                        .foregroundStyle(.secondary)
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

    // MARK: - Session Type Card

    private var typeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Type")
                .font(.subheadline)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SessionType.allCases, id: \.self) { sessionType in
                        let isSelected = presenter.sessionType == sessionType
                        VStack(spacing: 6) {
                            Image(systemName: sessionType.iconName)
                                .font(.title3)
                            Text(sessionType.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 76, height: 70)
                        .background(
                            isSelected ? presenter.beltAccentColor : Color(.systemGray6),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .foregroundStyle(isSelected ? .white : .primary)
                        .anyButton(.press) {
                            presenter.onSessionTypeSelected(sessionType)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Date & Duration Card

    private var dateAndDurationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker("Date & Time", selection: $presenter.date, displayedComponents: [.date, .hourAndMinute])

            Divider()

            VStack(spacing: 8) {
                Text("Duration")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 28) {
                    Button {
                        presenter.onDurationDecreased()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(presenter.beltAccentColor)
                    }

                    Text(presenter.durationText)
                        .font(.wazaStat)
                        .foregroundStyle(presenter.beltAccentColor)
                        .frame(minWidth: 90, alignment: .center)

                    Button {
                        presenter.onDurationIncreased()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(presenter.beltAccentColor)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Location Card

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            let hasData = !presenter.academy.isEmpty || !presenter.instructor.isEmpty
            collapsibleCardHeader(
                title: "Location",
                badge: hasData ? "•" : nil,
                isExpanded: $locationExpanded
            )

            if locationExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    TextField("Academy (optional)", text: $presenter.academy)
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                    TextField("Instructor (optional)", text: $presenter.instructor)
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(16)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipped()
    }

    // MARK: - Reflection Card

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            let hasData = [presenter.notes, presenter.whatWorkedWell, presenter.needsImprovement, presenter.keyInsights].contains { !$0.isEmpty }
            collapsibleCardHeader(
                title: "Reflection",
                badge: hasData ? "•" : nil,
                isExpanded: $reflectionExpanded
            )

            if reflectionExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    reflectionField("Notes", text: $presenter.notes, lines: 3...6)
                    reflectionField("What worked well?", text: $presenter.whatWorkedWell, lines: 2...4)
                    reflectionField("Needs improvement", text: $presenter.needsImprovement, lines: 2...4)
                    reflectionField("Key insights", text: $presenter.keyInsights, lines: 2...4)
                }
                .padding(16)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipped()
    }

    private func reflectionField(_ label: String, text: Binding<String>, lines: ClosedRange<Int>) -> some View {
        TextField(label, text: text, axis: .vertical)
            .lineLimit(lines)
            .padding(12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            let hasStat = presenter.showMoodSection || presenter.roundsCount > 0
            collapsibleCardHeader(
                title: "Stats",
                badge: hasStat ? "•" : nil,
                isExpanded: $statsExpanded
            )

            if statsExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Track mood", isOn: $presenter.showMoodSection)

                    if presenter.showMoodSection {
                        moodRow(label: "Before", isBefore: true, value: $presenter.preSessionMood)
                        moodRow(label: "After", isBefore: false, value: $presenter.postSessionMood)
                        Divider()
                    }

                    HStack {
                        Text("Rounds")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Stepper("\(presenter.roundsCount)", value: $presenter.roundsCount, in: 0...20)
                    }
                }
                .padding(16)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipped()
    }

    private func moodRow(label: String, isBefore: Bool, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { rating in
                    Text(moodEmojis[rating - 1])
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            value.wrappedValue == rating ? presenter.beltAccentColor.opacity(0.15) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(value.wrappedValue == rating ? presenter.beltAccentColor : Color.clear, lineWidth: 1.5)
                        )
                        .anyButton {
                            presenter.onMoodSelected(isBefore: isBefore, rating: rating)
                        }
                }
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        ZStack {
            Text("Save Session")
                .font(.headline)
                .foregroundStyle(.white)
                .opacity(presenter.isLoading ? 0 : 1)

            if presenter.isLoading {
                ProgressView()
                    .tint(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(presenter.beltAccentColor, in: RoundedRectangle(cornerRadius: 14))
        .anyButton(.press) {
            presenter.onSavePressed()
        }
    }

    // MARK: - Collapsible Card Header

    private func collapsibleCardHeader(title: String, badge: String?, isExpanded: Binding<Bool>) -> some View {
        Button {
            presenter.onSectionHeaderTapped()
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(presenter.beltAccentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(presenter.beltAccentColor.opacity(0.12), in: Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isExpanded.wrappedValue ? 90 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded.wrappedValue)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
