import SwiftUI

struct SessionEntryView: View {
    @State var presenter: SessionEntryPresenter
    let delegate: SessionEntryDelegate

    @State private var locationExpanded = false
    @State private var reflectionExpanded = true
    @State private var statsExpanded = false

    private let moodEmojis = Mood.emojis
    private let moodLabels = Mood.labels

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    typeCard
                    focusAreasCard
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
                    // Button required by SwiftUI ToolbarItem API
                    Button("Cancel") { presenter.onCancelPressed() }
                        .foregroundStyle(.secondary)
                }
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
                .wazaLabelStyle()

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
                            isSelected ? Color.wazaAccent : Color(.systemGray6),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .foregroundStyle(isSelected ? .white : .primary)
                        .scaleEffect(isSelected ? 1.0 : 0.96)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        .anyButton(.press) {
                            presenter.onSessionTypeSelected(sessionType)
                        }
                    }
                }
            }
        }
        .padding(16)
        .wazaCard()
    }

    // MARK: - Focus Areas Card

    private var focusAreasCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Areas")
                .wazaLabelStyle()

            let customAreas = presenter.selectedFocusAreas
                .filter { area in !SessionEntryPresenter.presetFocusAreas.contains(where: { $0.caseInsensitiveCompare(area) == .orderedSame }) }
                .sorted()
            let allAreas = SessionEntryPresenter.presetFocusAreas + customAreas

            FlowLayout(spacing: 8) {
                ForEach(allAreas, id: \.self) { area in
                    let isSelected = presenter.selectedFocusAreas.contains(area)
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
                        .scaleEffect(isSelected ? 1.0 : 0.96)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        .anyButton(.press) {
                            presenter.onFocusAreaToggled(area)
                        }
                }
            }

            HStack(spacing: 8) {
                TextField("Add custom area...", text: $presenter.customFocusAreaText)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                    .submitLabel(.done)
                    .onSubmit { presenter.onAddCustomFocusArea() }

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.wazaAccent)
                    .accessibilityLabel("Add custom focus area")
                    .anyButton {
                        presenter.onAddCustomFocusArea()
                    }
            }
        }
        .padding(16)
        .wazaCard()
    }

    // MARK: - Date & Duration Card

    private var dateAndDurationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker("Date & Time", selection: $presenter.date, displayedComponents: [.date, .hourAndMinute])

            Divider()

            VStack(spacing: 8) {
                Text("Duration")
                    .wazaLabelStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 28) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.wazaAccent)
                        .accessibilityLabel("Decrease duration")
                        .anyButton {
                            presenter.onDurationDecreased()
                        }

                    Text(presenter.durationText)
                        .font(.wazaStat)
                        .foregroundStyle(Color.wazaAccent)
                        .contentTransition(.numericText())
                        .frame(minWidth: 90, alignment: .center)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: presenter.durationMinutes)

                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.wazaAccent)
                        .accessibilityLabel("Increase duration")
                        .anyButton {
                            presenter.onDurationIncreased()
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .wazaCard()
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
                    .transition(.opacity)

                VStack(spacing: 10) {
                    if !presenter.savedGyms.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Academy")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(presenter.savedGyms) { gym in
                                        gymChip(gym: gym)
                                    }
                                    otherGymChip
                                }
                            }

                            if presenter.isCustomAcademy {
                                TextField("Academy name", text: $presenter.academy)
                                    .padding(12)
                                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    } else {
                        TextField("Academy (optional)", text: $presenter.academy)
                            .padding(12)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                    }

                    TextField("Instructor (optional)", text: $presenter.instructor)
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(16)
            }
        }
        .wazaCard()
        .clipped()
    }

    private func gymChip(gym: GymLocationModel) -> some View {
        let isSelected = presenter.selectedGymId == gym.gymId
        return Text(gym.name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.wazaAccent : Color(.systemGray6),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .anyButton(.press) {
                presenter.onGymSelected(gym.gymId)
            }
    }

    private var otherGymChip: some View {
        Text("Other")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                presenter.isCustomAcademy ? Color.wazaAccent : Color(.systemGray6),
                in: Capsule()
            )
            .foregroundStyle(presenter.isCustomAcademy ? .white : .primary)
            .anyButton(.press) {
                presenter.onGymSelected(nil)
            }
    }

    // MARK: - Reflection Card

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            let hasData = [presenter.whatWorkedWell, presenter.needsImprovement].contains(where: { !$0.isEmpty })
            reflectionCardHeader(hasData: hasData)

            if reflectionExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    reflectionField("What went well? Techniques that clicked, wins...", text: $presenter.whatWorkedWell, lines: 3...6)
                    reflectionField("What to work on? Struggles, areas to drill next...", text: $presenter.needsImprovement, lines: 3...6)
                }
                .padding(16)
            }
        }
        .wazaCard()
        .clipped()
    }

    private func reflectionCardHeader(hasData: Bool) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.caption)
                    .foregroundStyle(Color.wazaAccent)
                Text("Reflection")
                    .wazaLabelStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasData {
                Text("•")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.wazaAccent.opacity(0.12), in: Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
                .rotationEffect(.degrees(reflectionExpanded ? 90 : 0))
                .animation(.easeInOut(duration: 0.2), value: reflectionExpanded)
        }
        .padding(16)
        .contentShape(Rectangle())
        .anyButton(.plain) {
            presenter.onSectionHeaderTapped()
            withAnimation(.easeInOut(duration: 0.2)) {
                reflectionExpanded.toggle()
            }
        }
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
        .wazaCard()
        .clipped()
    }

    private func moodRow(label: String, isBefore: Bool, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { rating in
                    let isSelected = value.wrappedValue == rating
                    Text(moodEmojis[rating - 1])
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            isSelected ? Color.wazaAccent.opacity(0.15) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.wazaAccent : Color.clear, lineWidth: 1.5)
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        .accessibilityLabel("\(moodLabels[rating - 1]), mood \(rating) of 5")
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
        .background(Color.wazaAccent, in: RoundedRectangle(cornerRadius: 14))
        .opacity(presenter.isLoading ? 0.6 : 1)
        .anyButton(.press) {
            presenter.onSavePressed()
        }
        .disabled(presenter.isLoading)
    }

    // MARK: - Collapsible Card Header

    private func collapsibleCardHeader(title: String, badge: String?, isExpanded: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .wazaLabelStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            if let badge {
                Text(badge)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.wazaAccent.opacity(0.12), in: Capsule())
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
        .anyButton(.plain) {
            presenter.onSectionHeaderTapped()
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.wrappedValue.toggle()
            }
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
