import SwiftUI

struct TechniqueJournalView: View {
    @State var presenter: TechniqueJournalPresenter
    @State private var showMapView: Bool = false
    @State private var showAddSheet: Bool = false

    var body: some View {
        Group {
            if showMapView {
                mapContent
            } else {
                listContent
            }
        }
        .navigationTitle("Technique Journal")
        .toolbarTitleDisplayMode(.inlineLarge)
        .searchable(text: $presenter.searchText, prompt: "Search techniques...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(Color.wazaAccent)
                        .accessibilityLabel("Add technique")
                        .anyButton {
                            presenter.onAddTechniqueTapped()
                            showAddSheet = true
                        }

                    Image(systemName: showMapView ? "list.bullet" : "square.grid.2x2")
                        .font(.headline)
                        .foregroundStyle(Color.wazaAccent)
                        .accessibilityLabel(showMapView ? "List view" : "Map view")
                        .anyButton {
                            showMapView.toggle()
                        }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTechniqueSheet(
                accentColor: Color.wazaAccent,
                onSave: { name, category in
                    presenter.interactor.createTechnique(name: name, category: category)
                }
            )
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - List Content

    private var listContent: some View {
        List {
            if presenter.groupedTechniques.isEmpty {
                emptyState
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .scaleAppear(delay: 0.1)
            } else {
                techniqueSections
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Map Content

    private var mapContent: some View {
        ScrollView {
            TechniqueMapView(
                groups: presenter.groupedTechniques.map { group in
                    (
                        category: group.category,
                        techniques: group.techniques.map { technique in
                            (name: technique.name, stage: technique.stage)
                        }
                    )
                },
                accentColor: Color.wazaAccent,
                onTechniqueTapped: { name in
                    if let technique = presenter.filteredTechniqueByName(name) {
                        presenter.onTechniqueTapped(technique)
                    }
                }
            )
            .padding(16)
        }
    }

    // MARK: - Technique Sections

    private var techniqueSections: some View {
        ForEach(presenter.groupedTechniques, id: \.category) { group in
            Section {
                ForEach(Array(group.techniques.enumerated()), id: \.element.id) { index, technique in
                    TechniqueRowView(
                        name: technique.name,
                        stage: technique.stage,
                        practiceCount: presenter.practiceCount(for: technique),
                        lastPracticed: presenter.lastPracticed(for: technique)?.relativeFormatted,
                        accentColor: Color.wazaAccent
                    )
                    .staggeredAppear(index: index)
                    .anyButton {
                        presenter.onTechniqueTapped(technique)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                }
            } header: {
                sectionHeader(category: group.category, techniques: group.techniques)
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(category: TechniqueCategory, techniques: [TechniqueModel]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: category.iconName)
                    .font(.caption)
                    .foregroundStyle(Color.wazaAccent)

                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(techniques.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5), in: Capsule())
            }

            stageBreakdownRow(techniques: techniques)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets())
    }

    /// Row of tinted pill chips showing how many techniques in this category sit at each stage.
    /// Only non-zero stages render, so early-game users see a compact summary.
    private func stageBreakdownRow(techniques: [TechniqueModel]) -> some View {
        let counts = Dictionary(grouping: techniques, by: \.stage)
            .mapValues { $0.count }
        let ordered: [ProgressionStage] = [.learning, .drilling, .applying, .polishing]

        return HStack(spacing: 6) {
            ForEach(ordered, id: \.self) { stage in
                if let count = counts[stage], count > 0 {
                    stageChip(stage: stage, count: count)
                }
            }
        }
    }

    private func stageChip(stage: ProgressionStage, count: Int) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(stage.color)
                .frame(width: 6, height: 6)
            Text("\(count) \(stage.displayName.lowercased())")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(stage.color.opacity(0.12), in: Capsule())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: "book.closed",
            title: "No Techniques Yet",
            subtitle: "Techniques are added from your session focus areas, or tap + to add one manually.",
            actionTitle: nil,
            onAction: nil
        )
    }
}

// MARK: - Add Technique Sheet

private struct AddTechniqueSheet: View {
    let accentColor: Color
    let onSave: (String, TechniqueCategory) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var category: TechniqueCategory = .uncategorized

    var body: some View {
        NavigationStack {
            Form {
                Section("Technique Name") {
                    TextField("e.g., Triangle Choke", text: $name)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TechniqueCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Add Technique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Text("Cancel")
                        .anyButton { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : accentColor)
                        .anyButton {
                            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            onSave(trimmed.capitalized, category)
                            dismiss()
                        }
                }
            }
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func techniqueJournalView(router: AnyRouter) -> some View {
        TechniqueJournalView(
            presenter: TechniqueJournalPresenter(
                router: CoreRouter(router: router, builder: self),
                interactor: interactor
            )
        )
    }

}

// MARK: - Router Extension

extension CoreRouter {

    func showTechniqueJournalView() {
        router.showScreen(.push) { router in
            builder.techniqueJournalView(router: router)
        }
    }

    func showTechniqueDetailView(technique: TechniqueModel) {
        router.showScreen(.push) { router in
            builder.techniqueDetailView(router: router, technique: technique)
        }
    }

}

// MARK: - Previews

#Preview("Technique Journal - With Data") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.techniqueJournalView(router: router)
    }
}

#Preview("Technique Journal - Empty") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.techniqueJournalView(router: router)
    }
}
