import SwiftUI
import SwiftfulUI

struct CLAGameDetailView: View {
    @State var presenter: CLAGameDetailPresenter

    var body: some View {
        Group {
            if let game = presenter.game {
                content(game: game)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $presenter.isShowingDiscoverySheet) {
            discoverySheet
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    @ViewBuilder
    private func content(game: CLAGameModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection(game: game)
                objectiveSection(game: game)
                constraintsSection(game: game)
                expectedDiscoveriesSection(game: game)
                practiceSection(game: game)
                discoveriesSection(game: game)

                if game.isCustom {
                    deleteSection
                }
            }
            .padding(16)
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func headerSection(game: CLAGameModel) -> some View {
        HStack(spacing: 8) {
            Label(game.position, systemImage: "figure.martial.arts")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray5))
                .clipShape(Capsule())

            Text(game.focusArea)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray5))
                .clipShape(Capsule())

            Spacer()

            Text(game.skillLevel.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(difficultyColor(game.skillLevel).opacity(0.15))
                .foregroundStyle(difficultyColor(game.skillLevel))
                .clipShape(Capsule())
        }
    }

    private func objectiveSection(game: CLAGameModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Objective")
            Text(game.objective)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func constraintsSection(game: CLAGameModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Constraints")

            if !game.taskConstraints.isEmpty {
                constraintGroup(title: "Task", icon: "checkmark.circle", items: game.taskConstraints)
            }
            if !game.environmentConstraints.isEmpty {
                constraintGroup(title: "Environment", icon: "globe", items: game.environmentConstraints)
            }
            if !game.individualConstraints.isEmpty {
                constraintGroup(title: "Individual", icon: "person.circle", items: game.individualConstraints)
            }
        }
    }

    private func constraintGroup(title: String, icon: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func expectedDiscoveriesSection(game: CLAGameModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("What to Discover")
            ForEach(game.expectedDiscoveries, id: \.self) { discovery in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(.yellow)
                        .font(.subheadline)
                    Text(discovery)
                        .font(.subheadline)
                }
            }
        }
    }

    private func practiceSection(game: CLAGameModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(game.timePracticed)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("times practiced")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Mark Practiced")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .anyButton {
                    presenter.onMarkPracticedTapped()
                }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func discoveriesSection(game: CLAGameModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("My Discoveries")
                Spacer()
                Text("+ Log")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                    .anyButton {
                        presenter.onLogDiscoveryTapped()
                    }
            }

            if game.discoveries.isEmpty {
                Text("No discoveries yet. Play the game and log what you find.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(game.discoveries.sorted { $0.date > $1.date }) { discovery in
                    discoveryRow(discovery)
                }
            }
        }
    }

    private func discoveryRow(_ discovery: GameDiscoveryModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(discovery.dateFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                starRating(discovery.successRating)
            }
            Text(discovery.text)
                .font(.subheadline)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func starRating(_ rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(star <= rating ? .yellow : .secondary)
            }
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            presenter.onDeleteGameTapped()
        } label: {
            Label("Delete Game", systemImage: "trash")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }

    private var discoverySheet: some View {
        NavigationStack {
            Form {
                Section("What did you discover?") {
                    TextField("Describe your discovery...", text: $presenter.discoveryText, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("How successful were you?") {
                    HStack {
                        ForEach(1...5, id: \.self) { rating in
                            Image(systemName: rating <= presenter.discoveryRating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundStyle(rating <= presenter.discoveryRating ? .yellow : .secondary)
                                .anyButton {
                                    presenter.discoveryRating = rating
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Log Discovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presenter.isShowingDiscoverySheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        presenter.onSubmitDiscovery()
                    }
                    .disabled(presenter.discoveryText.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - CoreBuilder Extension

extension CoreBuilder {
    func claGameDetailView(router: AnyRouter, delegate: CLAGameDetailDelegate) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        let presenter = CLAGameDetailPresenter(router: coreRouter, interactor: interactor, delegate: delegate)
        return CLAGameDetailView(presenter: presenter)
    }
}

// MARK: - Previews

#Preview("Game Detail") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.claGameDetailView(router: router, delegate: CLAGameDetailDelegate(gameId: "builtin-gr-01"))
    }
}
