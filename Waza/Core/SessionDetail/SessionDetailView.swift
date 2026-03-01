import SwiftUI

struct SessionDetailView: View {
    @State var presenter: SessionDetailPresenter
    let delegate: SessionDetailDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                if !presenter.session.focusAreas.isEmpty {
                    focusAreasCard
                }
                reflectionCard
                statsCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationTitle(presenter.session.sessionType.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if presenter.isEditing {
                    Button("Save") {
                        presenter.onSaveEditPressed()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(presenter.beltAccentColor)
                } else {
                    Menu {
                        Button("Edit Notes") {
                            presenter.onEditPressed()
                        }
                        Divider()
                        Button("Delete Session", role: .destructive) {
                            presenter.onDeletePressed()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(presenter.beltAccentColor)
                    }
                }
            }
            if presenter.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presenter.onCancelEditPressed()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .confirmationDialog(
            "Delete this session?",
            isPresented: $presenter.showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                presenter.onDeleteConfirmed()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Error", isPresented: Binding(
            get: { presenter.errorMessage != nil },
            set: { if !$0 { presenter.errorMessage = nil } }
        )) {
            Button("OK") { presenter.errorMessage = nil }
        } message: {
            Text(presenter.errorMessage ?? "")
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: presenter.session.sessionType.iconName)
                    .font(.title)
                    .foregroundStyle(presenter.beltAccentColor)
                    .frame(width: 60, height: 60)
                    .background(presenter.beltAccentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(presenter.beltAccentColor.opacity(0.2), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text(presenter.session.sessionType.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(presenter.session.dateFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            HStack(spacing: 8) {
                detailPill(icon: "clock", value: presenter.session.durationFormatted)
                if presenter.session.roundsCount > 0 {
                    detailPill(icon: "repeat", value: "\(presenter.session.roundsCount) \(presenter.session.roundsCount == 1 ? "round" : "rounds")")
                }
                if let academy = presenter.session.academy {
                    detailPill(icon: "mappin", value: academy)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func detailPill(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
        }
        .foregroundStyle(presenter.beltAccentColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(presenter.beltAccentColor.opacity(0.1), in: Capsule())
    }

    // MARK: - Focus Areas

    private var focusAreasCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus Areas")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            FlowLayout(spacing: 8) {
                ForEach(presenter.session.focusAreas, id: \.self) { area in
                    Text(area)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(presenter.beltAccentColor.opacity(0.12), in: Capsule())
                        .foregroundStyle(presenter.beltAccentColor)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Reflection Card

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reflection")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if presenter.isEditing {
                editingReflectionContent
            } else {
                readOnlyReflectionContent
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var readOnlyReflectionContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let notes = presenter.session.notes {
                reflectionRow(title: "Notes", content: notes, icon: "note.text")
            }
            if let worked = presenter.session.whatWorkedWell {
                reflectionRow(title: "What Worked", content: worked, icon: "checkmark.circle.fill")
            }
            if let improve = presenter.session.needsImprovement {
                reflectionRow(title: "Needs Work", content: improve, icon: "exclamationmark.circle.fill")
            }
            if let insights = presenter.session.keyInsights {
                reflectionRow(title: "Key Insight", content: insights, icon: "lightbulb.fill")
            }
            if presenter.session.notes == nil &&
               presenter.session.whatWorkedWell == nil &&
               presenter.session.needsImprovement == nil &&
               presenter.session.keyInsights == nil {
                Text("No notes recorded.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func reflectionRow(title: String, content: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(presenter.beltAccentColor)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(content)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var editingReflectionContent: some View {
        VStack(spacing: 12) {
            TextEditor(text: $presenter.editNotes)
                .frame(minHeight: 60)
                .overlay(alignment: .topLeading) {
                    if presenter.editNotes.isEmpty {
                        Text("Notes...")
                            .foregroundStyle(.tertiary)
                            .padding(4)
                            .allowsHitTesting(false)
                    }
                }
            TextEditor(text: $presenter.editWhatWorked)
                .frame(minHeight: 60)
                .overlay(alignment: .topLeading) {
                    if presenter.editWhatWorked.isEmpty {
                        Text("What worked well...")
                            .foregroundStyle(.tertiary)
                            .padding(4)
                            .allowsHitTesting(false)
                    }
                }
            TextEditor(text: $presenter.editNeedsImprovement)
                .frame(minHeight: 60)
                .overlay(alignment: .topLeading) {
                    if presenter.editNeedsImprovement.isEmpty {
                        Text("Needs improvement...")
                            .foregroundStyle(.tertiary)
                            .padding(4)
                            .allowsHitTesting(false)
                    }
                }
            TextEditor(text: $presenter.editKeyInsights)
                .frame(minHeight: 60)
                .overlay(alignment: .topLeading) {
                    if presenter.editKeyInsights.isEmpty {
                        Text("Key insights...")
                            .foregroundStyle(.tertiary)
                            .padding(4)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                if let pre = presenter.session.preSessionMood {
                    moodStat(label: "Before", emoji: moodEmoji(pre), value: pre)
                }
                if let post = presenter.session.postSessionMood {
                    if presenter.session.preSessionMood != nil {
                        Divider().frame(height: 40)
                    }
                    moodStat(label: "After", emoji: moodEmoji(post), value: post)
                }
                if presenter.session.preSessionMood == nil && presenter.session.postSessionMood == nil {
                    Text("No mood data recorded.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func moodStat(label: String, emoji: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
}

// MARK: - Simple Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var xPos: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if xPos + size.width > width, xPos > 0 {
                height += rowHeight + spacing
                xPos = 0
                rowHeight = 0
            }
            xPos += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var xPos = bounds.minX
        var yPos = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if xPos + size.width > bounds.maxX, xPos > bounds.minX {
                yPos += rowHeight + spacing
                xPos = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: xPos, y: yPos), proposal: ProposedViewSize(size))
            xPos += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func sessionDetailView(router: AnyRouter, delegate: SessionDetailDelegate) -> some View {
        SessionDetailView(
            presenter: SessionDetailPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

// MARK: - Preview

#Preview("Session Detail") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let session = BJJSessionModel.mock
    let delegate = SessionDetailDelegate(session: session)

    return RouterView { router in
        builder.sessionDetailView(router: router, delegate: delegate)
    }
}
