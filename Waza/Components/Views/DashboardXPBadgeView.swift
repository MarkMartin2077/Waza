import SwiftUI

struct DashboardXPBadgeView: View {
    let levelInfo: XPLevelInfo
    let fireRoundExpiresAt: Date?
    let streakTier: StreakTier
    let accentColor: Color

    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var fireRoundActive: Bool {
        guard let expiry = fireRoundExpiresAt else { return false }
        return expiry > now
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Text("Lv. \(levelInfo.level)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(accentColor.opacity(0.15), in: Capsule())

                Text(levelInfo.title)
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                if fireRoundActive {
                    fireRoundBadge
                } else if streakTier != .none {
                    streakBadge
                }
            }

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
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onReceive(timer) { newTime in
            now = newTime
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var fireRoundBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
            Text("2x")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
            if let expiry = fireRoundExpiresAt {
                Text(shortTime(until: expiry))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.orange.opacity(0.12), in: Capsule())
    }

    private var streakBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "bolt.fill")
                .font(.caption2)
                .foregroundStyle(accentColor)
            Text("+\(streakTier.bonusPercent)%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(accentColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(accentColor.opacity(0.12), in: Capsule())
    }

    private func shortTime(until date: Date) -> String {
        let remaining = max(0, date.timeIntervalSince(now))
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        if hours > 0 { return "\(hours)h" }
        return "\(minutes)m"
    }

    private var accessibilityText: String {
        var text = "Level \(levelInfo.level), \(levelInfo.title)"
        if fireRoundActive {
            text += ", fire round active, double XP"
        } else if streakTier != .none {
            text += ", \(streakTier.displayName) streak, plus \(streakTier.bonusPercent) percent"
        }
        return text
    }
}

#Preview("Scrapper 3 with streak") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 900),
        fireRoundExpiresAt: nil,
        streakTier: .silver,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Fire Round active") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 900),
        fireRoundExpiresAt: Date().addingTimeInterval(3600 * 12),
        streakTier: .silver,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Rookie 1 — no boosts") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 0),
        fireRoundExpiresAt: nil,
        streakTier: .none,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Legend") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 15000),
        fireRoundExpiresAt: nil,
        streakTier: .diamond,
        accentColor: .cyan
    )
    .padding()
}
