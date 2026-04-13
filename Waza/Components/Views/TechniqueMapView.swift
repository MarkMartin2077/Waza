import SwiftUI

struct TechniqueMapView: View {
    let groups: [(category: TechniqueCategory, techniques: [(name: String, stage: ProgressionStage)])]
    let accentColor: Color
    let onTechniqueTapped: ((String) -> Void)?

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 8)
    ]

    var body: some View {
        if groups.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(groups, id: \.category) { group in
                    categorySection(group: group)
                }
            }
        }
    }

    // MARK: - Category Section

    private func categorySection(group: (category: TechniqueCategory, techniques: [(name: String, stage: ProgressionStage)])) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: group.category.iconName)
                    .font(.caption)
                    .foregroundStyle(accentColor)

                Text(group.category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(group.techniques.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5), in: Capsule())
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(group.techniques, id: \.name) { item in
                    techniqueCell(name: item.name, stage: item.stage)
                }
            }
        }
    }

    // MARK: - Technique Cell

    private func techniqueCell(name: String, stage: ProgressionStage) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(stage.color.opacity(stage.opacity))
                .frame(height: 8)

            Text(name)
                .font(.caption2)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(stage.color.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(stage.color.opacity(stage.opacity * 0.5), lineWidth: 1)
        )
        .anyButton(.press) {
            onTechniqueTapped?(name)
        }
        .accessibilityLabel("\(name), \(stage.displayName)")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 44))
                .foregroundStyle(accentColor.opacity(0.4))

            Text("No Techniques")
                .font(.headline)

            Text("Your technique map will appear here once you have techniques logged.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Previews

#Preview("Populated") {
    TechniqueMapView(
        groups: [
            (
                category: .submissions,
                techniques: [
                    (name: "Triangle", stage: .drilling),
                    (name: "Armbar", stage: .applying),
                    (name: "Heel Hook", stage: .learning),
                    (name: "Choke", stage: .polishing)
                ]
            ),
            (
                category: .guardPlay,
                techniques: [
                    (name: "Guard Retention", stage: .applying),
                    (name: "Back Takes", stage: .drilling)
                ]
            ),
            (
                category: .takedowns,
                techniques: [
                    (name: "Double Leg", stage: .learning)
                ]
            )
        ],
        accentColor: Color.wazaAccent,
        onTechniqueTapped: { _ in }
    )
    .padding()
}

#Preview("Single Category") {
    TechniqueMapView(
        groups: [
            (
                category: .sweeps,
                techniques: [
                    (name: "Scissor Sweep", stage: .polishing),
                    (name: "Hip Bump", stage: .applying)
                ]
            )
        ],
        accentColor: Color.wazaAccent,
        onTechniqueTapped: { _ in }
    )
    .padding()
}

#Preview("Empty") {
    TechniqueMapView(
        groups: [],
        accentColor: Color.wazaAccent,
        onTechniqueTapped: nil
    )
    .padding()
}
