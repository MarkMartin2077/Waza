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
        }
        .foregroundStyle(isSelected ? .white : stage.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(
            isSelected ? stage.color : stage.color.opacity(0.1),
            in: Capsule()
        )
        .anyButton {
            onStageSelected(stage)
        }
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
