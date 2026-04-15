import SwiftUI

struct SessionFilterBarView: View {
    let selectedSessionTypes: Set<SessionType>
    let selectedAcademy: String?
    let selectedMood: Int?
    let availableAcademies: [String]
    let sessionTypeLabel: String
    let academyLabel: String
    let moodLabel: String
    let hasActiveFilters: Bool
    let onTypeToggled: (SessionType) -> Void
    let onAcademySelected: (String?) -> Void
    let onMoodSelected: (Int?) -> Void
    let onClearFilters: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                typeMenu
                academyMenu
                moodMenu

                if hasActiveFilters {
                    clearButton
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Type Menu

    private var typeMenu: some View {
        Menu {
            ForEach(SessionType.allCases, id: \.self) { type in
                Button {
                    onTypeToggled(type)
                } label: {
                    if selectedSessionTypes.contains(type) {
                        Label(type.displayName, systemImage: "checkmark")
                    } else {
                        Text(type.displayName)
                    }
                }
            }
        } label: {
            filterChip(
                title: sessionTypeLabel,
                icon: "line.3.horizontal.decrease",
                isActive: !selectedSessionTypes.isEmpty
            )
        }
    }

    // MARK: - Academy Menu

    private var academyMenu: some View {
        Menu {
            if selectedAcademy != nil {
                Button("All Gyms") {
                    onAcademySelected(nil)
                }
                Divider()
            }
            ForEach(availableAcademies, id: \.self) { academy in
                Button {
                    onAcademySelected(academy)
                } label: {
                    if selectedAcademy == academy {
                        Label(academy, systemImage: "checkmark")
                    } else {
                        Text(academy)
                    }
                }
            }
        } label: {
            filterChip(
                title: academyLabel,
                icon: "mappin",
                isActive: selectedAcademy != nil
            )
        }
        .disabled(availableAcademies.isEmpty)
        .opacity(availableAcademies.isEmpty ? 0.5 : 1)
    }

    // MARK: - Mood Menu

    private var moodMenu: some View {
        Menu {
            if selectedMood != nil {
                Button("Any Mood") {
                    onMoodSelected(nil)
                }
                Divider()
            }
            ForEach(1...5, id: \.self) { rating in
                Button {
                    onMoodSelected(rating)
                } label: {
                    if selectedMood == rating {
                        Label("\(Mood.emoji(for: rating)) \(Mood.label(for: rating))", systemImage: "checkmark")
                    } else {
                        Text("\(Mood.emoji(for: rating)) \(Mood.label(for: rating))")
                    }
                }
            }
        } label: {
            filterChip(
                title: moodLabel,
                icon: selectedMood == nil ? "face.smiling" : nil,
                isActive: selectedMood != nil
            )
        }
    }

    // MARK: - Clear Button

    private var clearButton: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .anyButton {
                onClearFilters()
            }
            .accessibilityLabel("Clear all filters")
    }

    // MARK: - Chip Builder

    private func filterChip(title: String, icon: String?, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(title)
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.wazaAccent.opacity(0.15) : Color(.systemGray6))
        .foregroundStyle(isActive ? Color.wazaAccent : .secondary)
        .clipShape(Capsule())
        // Force the chip to always size to its intrinsic content width. Without this,
        // when `title` changes (e.g. "Type" → "Competition"), SwiftUI's default layout
        // animation can freeze the capsule at the old width while the text has already
        // updated, causing mid-animation truncation and a snap at the end.
        .fixedSize(horizontal: true, vertical: false)
        .animation(.easeInOut(duration: 0.2), value: title)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .accessibilityLabel("\(title) filter\(isActive ? ", active" : "")")
    }
}

// MARK: - Previews

#Preview("No Filters") {
    SessionFilterBarView(
        selectedSessionTypes: [],
        selectedAcademy: nil,
        selectedMood: nil,
        availableAcademies: ["Gracie Barra", "10th Planet", "Alliance"],
        sessionTypeLabel: "Type",
        academyLabel: "Gym",
        moodLabel: "Mood",
        hasActiveFilters: false,
        onTypeToggled: { _ in },
        onAcademySelected: { _ in },
        onMoodSelected: { _ in },
        onClearFilters: { }
    )
}

#Preview("Active Filters") {
    SessionFilterBarView(
        selectedSessionTypes: [.gi, .noGi],
        selectedAcademy: "Gracie Barra",
        selectedMood: 5,
        availableAcademies: ["Gracie Barra", "10th Planet"],
        sessionTypeLabel: "2 Types",
        academyLabel: "Gracie Barra",
        moodLabel: "🔥",
        hasActiveFilters: true,
        onTypeToggled: { _ in },
        onAcademySelected: { _ in },
        onMoodSelected: { _ in },
        onClearFilters: { }
    )
}

#Preview("Single Type") {
    SessionFilterBarView(
        selectedSessionTypes: [.gi],
        selectedAcademy: nil,
        selectedMood: nil,
        availableAcademies: ["Gracie Barra"],
        sessionTypeLabel: "Gi",
        academyLabel: "Gym",
        moodLabel: "Mood",
        hasActiveFilters: true,
        onTypeToggled: { _ in },
        onAcademySelected: { _ in },
        onMoodSelected: { _ in },
        onClearFilters: { }
    )
}
