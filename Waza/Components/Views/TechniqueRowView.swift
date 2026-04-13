import SwiftUI

struct TechniqueRowView: View {
    let name: String?
    let stage: ProgressionStage?
    let practiceCount: Int
    let lastPracticed: String?
    let accentColor: Color

    var body: some View {
        HStack(spacing: 10) {
            stageIndicator

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    if let name {
                        Text(name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    practicePill
                }

                if let stage {
                    Text(stage.displayName)
                        .font(.caption2)
                        .foregroundStyle(stage.color)
                }

                if let lastPracticed {
                    Text(lastPracticed)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Stage Indicator

    private var stageIndicator: some View {
        Group {
            if let stage {
                RoundedRectangle(cornerRadius: 4)
                    .fill(stage.color.opacity(stage.opacity))
                    .frame(width: 4, height: 44)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: 4, height: 44)
            }
        }
    }

    // MARK: - Practice Pill

    private var practicePill: some View {
        HStack(spacing: 3) {
            Image(systemName: "repeat")
                .font(.caption2)
            Text("\(practiceCount)")
                .font(.caption2)
        }
        .foregroundStyle(accentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(accentColor.opacity(0.1), in: Capsule())
    }
}

// MARK: - Previews

#Preview("Full Data") {
    TechniqueRowView(
        name: "Triangle Choke",
        stage: .drilling,
        practiceCount: 7,
        lastPracticed: "Tuesday",
        accentColor: Color.wazaAccent
    )
    .padding()
}

#Preview("Polishing Stage") {
    TechniqueRowView(
        name: "Armbar",
        stage: .polishing,
        practiceCount: 21,
        lastPracticed: "Today",
        accentColor: Color.wazaAccent
    )
    .padding()
}

#Preview("Learning Stage") {
    TechniqueRowView(
        name: "Heel Hook",
        stage: .learning,
        practiceCount: 1,
        lastPracticed: nil,
        accentColor: Color.wazaAccent
    )
    .padding()
}

#Preview("No Date") {
    TechniqueRowView(
        name: "Guard Retention",
        stage: .applying,
        practiceCount: 12,
        lastPracticed: nil,
        accentColor: Color.wazaAccent
    )
    .padding()
}
