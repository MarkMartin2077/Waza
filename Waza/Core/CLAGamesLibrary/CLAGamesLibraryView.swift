import SwiftUI
import SwiftfulUI

struct CLAGamesLibraryView: View {
    @State var presenter: CLAGamesLibraryPresenter
    @State private var showCreateSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                positionFilterRow
                difficultyFilterRow
                gamesList
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationTitle("CLA Games")
        .searchable(text: $presenter.searchText, prompt: "Search games...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .anyButton {
                        presenter.onCreateGameTapped()
                    }
            }
        }
        .sheet(isPresented: $presenter.isShowingCreateSheet) {
            CreateGameSheetView { name, objective, skillLevel, position, focusArea in
                presenter.onCreateGame(
                    name: name,
                    objective: objective,
                    skillLevel: skillLevel,
                    position: position,
                    focusArea: focusArea
                )
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    private var positionFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(presenter.positions, id: \.self) { position in
                    filterChip(
                        title: position,
                        isSelected: presenter.selectedPosition == position
                    ) {
                        presenter.selectedPosition = position
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var difficultyFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BeltLevel.allCases, id: \.self) { level in
                    filterChip(
                        title: level.displayName,
                        isSelected: presenter.selectedDifficulty == level
                    ) {
                        presenter.selectedDifficulty = level
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gamesList: some View {
        LazyVStack(spacing: 12) {
            if presenter.filteredGames.isEmpty {
                emptyState
            } else {
                ForEach(presenter.filteredGames) { game in
                    CLAGameRowView(game: game) {
                        presenter.onGameTapped(game)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "puzzlepiece")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No games found")
                .font(.headline)
            Text("Try adjusting your filters or create a custom game.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private func filterChip(title: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .anyButton {
                onTap()
            }
    }
}

// MARK: - Row Component

struct CLAGameRowView: View {
    let game: CLAGameModel
    let onTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(game.name)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(game.skillLevel.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor(game.skillLevel).opacity(0.15))
                    .foregroundStyle(difficultyColor(game.skillLevel))
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                Label(game.position, systemImage: "figure.martial.arts")
                Text("·")
                Text(game.focusArea)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(game.objective)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if game.timePracticed > 0 || !game.discoveries.isEmpty {
                HStack(spacing: 12) {
                    if game.timePracticed > 0 {
                        Label("\(game.timePracticed)x practiced", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                    if !game.discoveries.isEmpty {
                        Label("\(game.discoveries.count) discoveries", systemImage: "lightbulb.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .anyButton {
            onTap?()
        }
    }

    private func difficultyColor(_ level: BeltLevel) -> Color {
        switch level {
        case .all: return .blue
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Create Game Sheet

struct CreateGameSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var objective: String = ""
    @State private var position: String = "Guard"
    @State private var focusArea: String = ""
    @State private var skillLevel: BeltLevel = .beginner

    let positions = ["Guard", "Passing", "Escapes", "Submissions", "Takedowns", "Positional"]
    let onSubmit: (String, String, BeltLevel, String, String) -> Void

    var isValid: Bool {
        !name.isEmpty && !objective.isEmpty && !focusArea.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Game Info") {
                    TextField("Name", text: $name)
                    Picker("Position", selection: $position) {
                        ForEach(positions, id: \.self) { Text($0) }
                    }
                    TextField("Focus Area (e.g. Guard Retention)", text: $focusArea)
                    Picker("Difficulty", selection: $skillLevel) {
                        ForEach(BeltLevel.allCases, id: \.self) {
                            Text($0.displayName).tag($0)
                        }
                    }
                }

                Section("Objective") {
                    TextField("What is the goal of this game?", text: $objective, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onSubmit(name, objective, skillLevel, position, focusArea)
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - CoreBuilder Extension

extension CoreBuilder {
    func claGamesLibraryView(router: AnyRouter) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        let presenter = CLAGamesLibraryPresenter(router: coreRouter, interactor: interactor)
        return CLAGamesLibraryView(presenter: presenter)
    }
}

// MARK: - Previews

#Preview("Library") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.claGamesLibraryView(router: router)
    }
}
