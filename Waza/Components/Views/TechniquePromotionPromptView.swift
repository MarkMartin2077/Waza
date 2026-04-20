import SwiftUI

struct TechniquePromotionPromptView: View {
    let techniqueName: String
    let currentStage: String
    let suggestedStage: String
    let practiceCount: Int
    let onPromote: (() -> Void)?
    let onSnooze: (() -> Void)?
    let onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.bottom, 16)

            titleSection
                .padding(.bottom, 8)

            statsLine
                .padding(.bottom, 20)

            promotionArrow
                .padding(.bottom, 24)

            promoteButton
                .padding(.bottom, 12)

            snoozeButton
        }
        .padding(24)
        .wazaCard(cornerRadius: .wazaCornerHero)
        .padding(.horizontal, 20)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .top) {
            Text("Technique Ready")
                .font(.wazaLabel)
                .wazaLabelStyle()
                .foregroundStyle(Color.wazaAccent)

            Spacer()

            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaInk500)
                    .frame(width: 28, height: 28)
                    .background(Color.wazaInk300, in: Circle())
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        Text(techniqueName)
            .font(.wazaDisplaySmall)
            .foregroundStyle(Color.wazaInk900)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats

    private var statsLine: some View {
        Text("Practiced \(practiceCount) times at \(currentStage)")
            .font(.wazaBody)
            .foregroundStyle(Color.wazaInk600)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Promotion Arrow

    private var promotionArrow: some View {
        HStack(spacing: 10) {
            Text(currentStage.uppercased())
                .font(.wazaLabel)
                .wazaLabelStyle()
                .foregroundStyle(Color.wazaInk500)

            Image(systemName: "arrow.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.wazaInk500)

            Text(suggestedStage.uppercased())
                .font(.wazaLabel)
                .wazaLabelStyle()
                .fontWeight(.bold)
                .foregroundStyle(Color.wazaAccent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(Color.wazaAccent.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .strokeBorder(Color.wazaAccent.opacity(0.2), lineWidth: 0.5)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Buttons

    private var promoteButton: some View {
        Text("Promote to \(suggestedStage)")
            .font(.wazaBody)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.wazaAccent, in: RoundedRectangle(cornerRadius: .wazaCornerSmall))
            .anyButton(.press) {
                onPromote?()
            }
    }

    private var snoozeButton: some View {
        Text("Not yet")
            .font(.wazaBody)
            .foregroundStyle(Color.wazaInk500)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .anyButton(.press) {
                onSnooze?()
            }
    }
}

// MARK: - Previews

#Preview("Learning → Drilling") {
    ZStack {
        Color.wazaPaper.ignoresSafeArea()
        TechniquePromotionPromptView(
            techniqueName: "Triangle from Guard",
            currentStage: "Learning",
            suggestedStage: "Drilling",
            practiceCount: 4,
            onPromote: { },
            onSnooze: { },
            onDismiss: { }
        )
    }
}

#Preview("Drilling → Applying") {
    ZStack {
        Color.wazaPaper.ignoresSafeArea()
        TechniquePromotionPromptView(
            techniqueName: "Rear Naked Choke",
            currentStage: "Drilling",
            suggestedStage: "Applying",
            practiceCount: 12,
            onPromote: { },
            onSnooze: { },
            onDismiss: { }
        )
    }
}

#Preview("Applying → Polishing") {
    ZStack {
        Color.wazaPaper.ignoresSafeArea()
        TechniquePromotionPromptView(
            techniqueName: "X-Guard Sweep",
            currentStage: "Applying",
            suggestedStage: "Polishing",
            practiceCount: 21,
            onPromote: { },
            onSnooze: { },
            onDismiss: { }
        )
    }
}
