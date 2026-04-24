import SwiftUI

/// One-time nudge shown on Home after the tab reorganization.
/// Points users to the new locations of features that moved.
struct ReorganizationNudgeView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                HankoView(kanji: "新", size: 40, rotation: -3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("We rearranged things")
                        .font(.wazaDisplaySmall)
                        .foregroundStyle(Color.wazaInk900)

                    Text("Here's where your favorites moved.")
                        .font(.wazaBody)
                        .italic()
                        .foregroundStyle(Color.wazaInk500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(Color.wazaInk500)
                    .padding(6)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Dismiss")
                    .anyButton { onDismiss() }
            }

            Divider().background(Color.wazaInk300)

            VStack(alignment: .leading, spacing: 10) {
                nudgeRow(
                    icon: "figure.wrestling",
                    title: "Train",
                    detail: "Sessions, Techniques, and Schedule"
                )
                nudgeRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress",
                    detail: "Achievements, Reports, and Belt progress"
                )
            }
        }
        .padding(16)
        .wazaCard()
    }

    private func nudgeRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .fill(Color.wazaAccent.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaInk900)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color.wazaInk500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ReorganizationNudgeView(onDismiss: { })
        .padding()
        .background(Color.wazaPaper)
}
