import SwiftUI

struct ProgressionStagePicker: View {
    let selectedStage: ProgressionStage
    let onStageSelected: (ProgressionStage) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(ProgressionStage.allCases, id: \.self) { stage in
                stageCapsule(stage: stage)
            }
        }
    }

    // MARK: - Stage Capsule

    private func stageCapsule(stage: ProgressionStage) -> some View {
        let isSelected = stage == selectedStage

        return HStack(spacing: 4) {
            Image(systemName: stage.iconName)
                .font(.caption2)
            Text(stage.displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                // Force single line — without this, "Polishing" wraps on narrow devices
                // and makes its capsule taller than the others.
                .lineLimit(1)
                // Allow very mild shrinking (~85%) before truncation so the full word
                // fits without an ellipsis on iPhone 15 Pro and smaller.
                .minimumScaleFactor(0.85)
        }
        .foregroundStyle(isSelected ? .white : stage.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(
            isSelected ? stage.color : stage.color.opacity(0.1),
            in: Capsule()
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .anyButton {
            onStageSelected(stage)
        }
        .accessibilityLabel("\(stage.displayName)\(isSelected ? ", selected" : "")")
    }
}

// MARK: - Previews

#Preview("Learning Selected") {
    ProgressionStagePicker(
        selectedStage: .learning,
        onStageSelected: { _ in }
    )
    .padding()
}

#Preview("Drilling Selected") {
    ProgressionStagePicker(
        selectedStage: .drilling,
        onStageSelected: { _ in }
    )
    .padding()
}

#Preview("Applying Selected") {
    ProgressionStagePicker(
        selectedStage: .applying,
        onStageSelected: { _ in }
    )
    .padding()
}

#Preview("Polishing Selected") {
    ProgressionStagePicker(
        selectedStage: .polishing,
        onStageSelected: { _ in }
    )
    .padding()
}
