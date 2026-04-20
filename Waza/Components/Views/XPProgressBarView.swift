import SwiftUI

struct XPProgressBarView: View {
    let levelInfo: XPLevelInfo
    let accentColor: Color

    private var isLegend: Bool {
        levelInfo.league == .legend
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Lv. \(levelInfo.level)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(accentColor.opacity(0.15), in: Capsule())

                Text(levelInfo.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(levelInfo.currentXP) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isLegend {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundStyle(accentColor)
                    Text("Max Rank Achieved")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 4) {
                    // Matches Dashboard XP badge progress bar height (4pt) for visual
                    // consistency across screens where level info appears.
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(accentColor)
                                .frame(width: geo.size.width * min(levelInfo.progressToNextLevel, 1.0), height: 4)
                                .animation(.easeOut(duration: 0.5), value: levelInfo.progressToNextLevel)
                        }
                    }
                    .frame(height: 4)

                    if let next = levelInfo.xpForNextLevel {
                        Text("\(levelInfo.currentXP - levelInfo.xpForCurrentLevel) / \(next - levelInfo.xpForCurrentLevel) XP to next level")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .padding(14)
        .wazaCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        if isLegend {
            return "Level \(levelInfo.level), \(levelInfo.title), \(levelInfo.currentXP) XP total, max rank achieved"
        }
        let percent = Int(levelInfo.progressToNextLevel * 100)
        return "Level \(levelInfo.level), \(levelInfo.title), \(levelInfo.currentXP) XP total, \(percent) percent to next level"
    }
}

#Preview("Rookie 1 — 0 XP") {
    XPProgressBarView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 0),
        accentColor: .cyan
    )
    .padding()
}

#Preview("Scrapper 3 — mid progress") {
    XPProgressBarView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 900),
        accentColor: .cyan
    )
    .padding()
}

#Preview("Adept 1 — just promoted") {
    let adeptXP = XPLevelSystem.xpRequired(forLevel: 21)
    return XPProgressBarView(
        levelInfo: XPLevelSystem.levelInfo(forXP: adeptXP),
        accentColor: .cyan
    )
    .padding()
}

#Preview("Legend") {
    let legendXP = XPLevelSystem.xpRequired(forLevel: 41)
    return XPProgressBarView(
        levelInfo: XPLevelSystem.levelInfo(forXP: legendXP + 500),
        accentColor: .cyan
    )
    .padding()
}

#Preview("Zero XP") {
    XPProgressBarView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 0),
        accentColor: .cyan
    )
    .padding()
}
