import SwiftUI

struct TechniqueDetailView: View {
    @State var presenter: TechniqueDetailPresenter
    @State private var isEditingNotes: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                stagePicker

                if let suggestion = presenter.promotionSuggestion {
                    promotionBanner(suggestion: suggestion)
                }

                statsCard

                notesCard

                if !presenter.relatedSessions.isEmpty {
                    sessionHistoryCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationTitle(presenter.technique.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Delete Technique", role: .destructive) {
                        presenter.onDeletePressed()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.wazaAccent)
                }
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Stage Picker

    private var stagePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progression Stage")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ProgressionStagePicker(
                selectedStage: presenter.technique.stage,
                onStageSelected: { presenter.onStageChanged($0) }
            )
        }
        .padding(16)
        .wazaCard()
    }

    // MARK: - Promotion Banner

    private func promotionBanner(suggestion: ProgressionStage) -> some View {
        HStack(spacing: 12) {
            Image(systemName: suggestion.iconName)
                .font(.title3)
                .foregroundStyle(suggestion.color)

            VStack(alignment: .leading, spacing: 2) {
                Text("Ready to Promote?")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("You've practiced enough to move to \(suggestion.displayName).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Promote")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(suggestion.color, in: Capsule())
                .anyButton(.press) {
                    presenter.onStageChanged(suggestion)
                }
        }
        .padding(14)
        .background(suggestion.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(suggestion.color.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                statItem(label: "Sessions", value: "\(presenter.practiceCount)")
                Divider().frame(height: 44)
                statItem(label: "Last Practiced", value: presenter.lastPracticed?.relativeFormatted ?? "Never")
                Divider().frame(height: 44)
                statItem(label: "Added", value: presenter.technique.createdDate.shortFormatted)
            }
        }
        .padding(16)
        .wazaCard()
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !isEditingNotes {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundStyle(Color.wazaAccent)
                        .anyButton {
                            isEditingNotes = true
                        }
                } else {
                    HStack(spacing: 12) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .anyButton {
                                presenter.editNotes = presenter.technique.notes ?? ""
                                isEditingNotes = false
                            }

                        Text("Save")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.wazaAccent)
                            .anyButton {
                                presenter.onNotesSaved(presenter.editNotes)
                                isEditingNotes = false
                            }
                    }
                }
            }

            if isEditingNotes {
                TextEditor(text: $presenter.editNotes)
                    .frame(minHeight: 80)
                    .overlay(alignment: .topLeading) {
                        if presenter.editNotes.isEmpty {
                            Text("Add notes about this technique...")
                                .foregroundStyle(.tertiary)
                                .padding(4)
                                .allowsHitTesting(false)
                        }
                    }
            } else if let notes = presenter.technique.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No notes yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .wazaCard()
    }

    // MARK: - Session History Card

    private var sessionHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session History")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(presenter.relatedSessions.prefix(5)) { session in
                SessionRowView(session: session, accentColor: Color.wazaAccent)
                    .anyButton {
                        presenter.onSessionTapped(session)
                    }
            }

            if presenter.relatedSessions.count > 5 {
                Text("+ \(presenter.relatedSessions.count - 5) more sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .wazaCard()
    }

}

// MARK: - Builder Extension

extension CoreBuilder {

    func techniqueDetailView(router: AnyRouter, technique: TechniqueModel) -> some View {
        TechniqueDetailView(
            presenter: TechniqueDetailPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                technique: technique
            )
        )
    }

}

// MARK: - Previews

#Preview("Technique Detail") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let technique = TechniqueModel.mock

    return RouterView { router in
        builder.techniqueDetailView(router: router, technique: technique)
    }
}
