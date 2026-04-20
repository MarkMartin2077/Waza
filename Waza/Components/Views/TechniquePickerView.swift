import SwiftUI

// MARK: - Supporting Type

struct TechniquePickerItem: Identifiable {
    var id: String { name }
    let name: String
    let category: String  // display name of category
    let stage: String     // display name of stage (Learning, Drilling, etc.)
    let isSelected: Bool
}

// MARK: - TechniquePickerView

struct TechniquePickerView: View {
    let techniques: [TechniquePickerItem]
    let selectedNames: Set<String>
    let onTechniqueToggled: ((TechniquePickerItem) -> Void)?
    let onAddNewTapped: ((String) -> Void)?

    // Search text is local UI state — not data, just drives filtering
    @State private var searchText: String = ""

    // MARK: - Derived

    private var filtered: [TechniquePickerItem] {
        guard !searchText.isEmpty else { return techniques }
        return techniques.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var showAddNew: Bool {
        guard !searchText.isEmpty else { return false }
        return !techniques.contains { $0.name.localizedCaseInsensitiveContains(searchText) && $0.name.lowercased() == searchText.lowercased() }
    }

    /// Group by category when the list is long enough to benefit from it
    private var useGrouped: Bool { techniques.count > 8 }

    private var groupedFiltered: [(category: String, items: [TechniquePickerItem])] {
        let dict = Dictionary(grouping: filtered, by: \.category)
        return dict.keys.sorted().map { key in (category: key, items: dict[key]!) }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchField
                .padding(.bottom, 12)

            if techniques.isEmpty && searchText.isEmpty {
                emptyState
            } else {
                techniqueList
            }
        }
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(Color.wazaInk400)

            TextField("Search techniques...", text: $searchText)
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk900)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.wazaInk400)
                    .anyButton(.press) {
                        searchText = ""
                    }
                    .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerStandard)
                .fill(Color.wazaPaperHi)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .wazaCornerStandard)
                .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
        )
    }

    // MARK: - Technique List

    @ViewBuilder
    private var techniqueList: some View {
        VStack(spacing: 0) {
            if useGrouped && searchText.isEmpty {
                groupedList
            } else {
                flatList
            }

            if showAddNew {
                addNewRow
            }
        }
    }

    // MARK: - Flat List

    private var flatList: some View {
        VStack(spacing: 0) {
            if filtered.isEmpty && !searchText.isEmpty {
                noResultsState
            } else {
                ForEach(filtered) { item in
                    techniqueRow(item)
                    if item.id != filtered.last?.id {
                        Divider()
                            .background(Color.wazaInk200)
                            .padding(.leading, 44)
                    }
                }
            }
        }
        .wazaCard()
    }

    // MARK: - Grouped List

    @ViewBuilder
    private var groupedList: some View {
        ForEach(groupedFiltered, id: \.category) { group in
            VStack(spacing: 0) {
                Text(group.category)
                    .wazaLabelStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ForEach(group.items) { item in
                    techniqueRow(item)
                    if item.id != group.items.last?.id {
                        Divider()
                            .background(Color.wazaInk200)
                            .padding(.leading, 44)
                    }
                }
            }
            .wazaCard()

            Spacer().frame(height: 8)
        }
    }

    // MARK: - Technique Row

    private func techniqueRow(_ item: TechniquePickerItem) -> some View {
        HStack(spacing: 12) {
            // Selection circle
            Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(item.isSelected ? Color.wazaAccent : Color.wazaInk300)
                .animation(.easeInOut(duration: 0.15), value: item.isSelected)

            // Name
            Text(item.name)
                .font(.wazaDisplaySmall)
                .foregroundStyle(Color.wazaInk900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            // Stage label
            Text(item.stage.uppercased())
                .wazaLabelStyle()
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .anyButton(.press) {
            onTechniqueToggled?(item)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.name), \(item.stage)\(item.isSelected ? ", selected" : "")")
        .accessibilityAddTraits(item.isSelected ? [.isSelected] : [])
    }

    // MARK: - Add New Row

    private var addNewRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle")
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)

            Text("Add \"\(searchText)\" as new technique")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .anyButton(.press) {
            onAddNewTapped?(searchText)
        }
        .wazaCard()
        .padding(.top, 8)
        .accessibilityLabel("Add \"\(searchText)\" as new technique")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Text("No techniques yet. Add your first during a session.")
            .font(.wazaBody)
            .foregroundStyle(Color.wazaInk500)
            .multilineTextAlignment(.center)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
    }

    private var noResultsState: some View {
        Text("No techniques match \"\(searchText)\".")
            .font(.wazaBody)
            .foregroundStyle(Color.wazaInk500)
            .multilineTextAlignment(.center)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#Preview("Full List — Some Selected") {
    ScrollView {
        TechniquePickerView(
            techniques: [
                TechniquePickerItem(name: "Triangle Choke", category: "Submissions", stage: "Drilling", isSelected: true),
                TechniquePickerItem(name: "Armbar", category: "Submissions", stage: "Applying", isSelected: false),
                TechniquePickerItem(name: "Rear Naked Choke", category: "Submissions", stage: "Polishing", isSelected: true),
                TechniquePickerItem(name: "Guard Pass", category: "Guard Passing", stage: "Learning", isSelected: false),
                TechniquePickerItem(name: "Double Leg Takedown", category: "Takedowns", stage: "Drilling", isSelected: false),
                TechniquePickerItem(name: "Kimura", category: "Submissions", stage: "Applying", isSelected: false),
                TechniquePickerItem(name: "X-Guard Sweep", category: "Guard", stage: "Learning", isSelected: false),
            ],
            selectedNames: ["Triangle Choke", "Rear Naked Choke"],
            onTechniqueToggled: { item in print("Toggled: \(item.name)") },
            onAddNewTapped: { name in print("Add new: \(name)") }
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .background(Color.wazaPaper)
}

#Preview("Grouped — Many Techniques") {
    ScrollView {
        TechniquePickerView(
            techniques: [
                TechniquePickerItem(name: "Triangle Choke", category: "Submissions", stage: "Drilling", isSelected: true),
                TechniquePickerItem(name: "Armbar", category: "Submissions", stage: "Applying", isSelected: false),
                TechniquePickerItem(name: "Rear Naked Choke", category: "Submissions", stage: "Polishing", isSelected: false),
                TechniquePickerItem(name: "Guillotine", category: "Submissions", stage: "Learning", isSelected: false),
                TechniquePickerItem(name: "Kimura", category: "Submissions", stage: "Applying", isSelected: false),
                TechniquePickerItem(name: "Guard Pass", category: "Guard Passing", stage: "Learning", isSelected: false),
                TechniquePickerItem(name: "Torreando Pass", category: "Guard Passing", stage: "Drilling", isSelected: false),
                TechniquePickerItem(name: "Double Leg Takedown", category: "Takedowns", stage: "Drilling", isSelected: false),
                TechniquePickerItem(name: "Single Leg Takedown", category: "Takedowns", stage: "Learning", isSelected: false),
                TechniquePickerItem(name: "X-Guard Sweep", category: "Guard", stage: "Learning", isSelected: false),
                TechniquePickerItem(name: "De La Riva Hook", category: "Guard", stage: "Drilling", isSelected: true),
            ],
            selectedNames: ["Triangle Choke", "De La Riva Hook"],
            onTechniqueToggled: { item in print("Toggled: \(item.name)") },
            onAddNewTapped: { name in print("Add new: \(name)") }
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .background(Color.wazaPaper)
}

#Preview("Empty State") {
    TechniquePickerView(
        techniques: [],
        selectedNames: [],
        onTechniqueToggled: nil,
        onAddNewTapped: nil
    )
    .padding(.horizontal, 16)
    .background(Color.wazaPaper)
}

#Preview("Search — Add New Visible") {
    // Simulates a search term that doesn't match any technique
    // The @State searchText is internal, so we show the component
    // at rest — the "Add new" row appears once the user types.
    TechniquePickerView(
        techniques: [
            TechniquePickerItem(name: "Triangle Choke", category: "Submissions", stage: "Drilling", isSelected: false),
            TechniquePickerItem(name: "Armbar", category: "Submissions", stage: "Applying", isSelected: false),
        ],
        selectedNames: [],
        onTechniqueToggled: { item in print("Toggled: \(item.name)") },
        onAddNewTapped: { name in print("Add new: \(name)") }
    )
    .padding(.horizontal, 16)
    .background(Color.wazaPaper)
}
