import SwiftUI

/// Consolidated dashboard status strip — shows level, title, streak, freezes, and
/// any active bonus (fire round or streak tier) in one compact row. Also surfaces
/// a streak-at-risk warning with an inline "Use Freeze" action when applicable,
/// replacing the need for a separate full-width risk banner.
struct DashboardXPBadgeView: View {
    let levelInfo: XPLevelInfo
    let fireRoundExpiresAt: Date?
    let streakTier: StreakTier
    let streakCount: Int
    let isStreakAtRisk: Bool
    let freezesAvailable: Int
    let perfectWeekActive: Bool
    let onUseFreezePressed: (() -> Void)?
    let accentColor: Color

    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var fireRoundActive: Bool {
        guard let expiry = fireRoundExpiresAt else { return false }
        return expiry > now
    }

    private var showsRiskWarning: Bool {
        isStreakAtRisk && streakCount >= 2
    }

    private var isBrandNew: Bool {
        levelInfo.level == 1 && levelInfo.currentXP == 0 && streakCount == 0
    }

    var body: some View {
        VStack(spacing: 8) {
            topRow
            progressBar
            if showsRiskWarning {
                riskRow
            } else if isBrandNew {
                brandNewHintRow
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .strokeBorder(showsRiskWarning ? Color.orange.opacity(0.5) : .clear, lineWidth: 1)
                )
        )
        .onReceive(timer) { newTime in
            now = newTime
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Top Row

    private var topRow: some View {
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
                .lineLimit(1)

            Spacer()

            if streakCount > 0 {
                streakChip
            }

            if fireRoundActive {
                fireRoundBadge
            } else if perfectWeekActive {
                perfectWeekBadge
            } else if streakTier != .none {
                tierBadge
            }
        }
    }

    private var perfectWeekBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(.yellow)
            Text("Perfect Week")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Color.yellow.opacity(0.12), in: Capsule())
    }

    private var streakChip: some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundStyle(showsRiskWarning ? .orange : accentColor)
            Text("\(streakCount)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(showsRiskWarning ? .orange : .primary)
                .contentTransition(.numericText())
        }
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
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Color.orange.opacity(0.12), in: Capsule())
    }

    private var tierBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "bolt.fill")
                .font(.caption2)
                .foregroundStyle(accentColor)
            Text("+\(streakTier.bonusPercent)%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(accentColor)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(accentColor.opacity(0.12), in: Capsule())
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
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

    // MARK: - Risk Row

    private var riskRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.orange)

            Text(riskText)
                .font(.caption2)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if freezesAvailable > 0, let onUseFreezePressed {
                Text("Use Freeze")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange, in: Capsule())
                    .anyButton(.press) {
                        onUseFreezePressed()
                    }
            }
        }
    }

    private var riskText: String {
        if freezesAvailable > 0 {
            return "Streak expires today · \(freezesAvailable) freeze\(freezesAvailable == 1 ? "" : "s") ready"
        }
        return "Streak expires today — train to keep it alive"
    }

    /// Inline hint for brand-new accounts so the empty strip feels inviting rather than blank.
    private var brandNewHintRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.caption2)
                .foregroundStyle(accentColor)
            Text("Log your first session to start your streak")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helpers

    private func shortTime(until date: Date) -> String {
        let remaining = max(0, date.timeIntervalSince(now))
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        if hours > 0 { return "\(hours)h" }
        return "\(minutes)m"
    }

    private var accessibilityText: String {
        var text = "Level \(levelInfo.level), \(levelInfo.title)"
        if streakCount > 0 {
            text += ", \(streakCount) day streak"
        }
        if fireRoundActive {
            text += ", fire round active, double XP"
        } else if streakTier != .none {
            text += ", \(streakTier.displayName) tier plus \(streakTier.bonusPercent) percent"
        }
        if showsRiskWarning {
            text += ", streak at risk today"
            if freezesAvailable > 0 {
                text += ", \(freezesAvailable) freezes available"
            }
        }
        return text
    }
}

// MARK: - Previews

#Preview("Scrapper 3 — streak, no risk") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 900),
        fireRoundExpiresAt: nil,
        streakTier: .silver,
        streakCount: 7,
        isStreakAtRisk: false,
        freezesAvailable: 1,
        perfectWeekActive: false,
        onUseFreezePressed: nil,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Fire Round active") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 900),
        fireRoundExpiresAt: Date().addingTimeInterval(3600 * 12),
        streakTier: .silver,
        streakCount: 12,
        isStreakAtRisk: false,
        freezesAvailable: 0,
        perfectWeekActive: false,
        onUseFreezePressed: nil,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Rookie — no streak, no boosts") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 0),
        fireRoundExpiresAt: nil,
        streakTier: .none,
        streakCount: 0,
        isStreakAtRisk: false,
        freezesAvailable: 0,
        perfectWeekActive: false,
        onUseFreezePressed: nil,
        accentColor: .cyan
    )
    .padding()
}

#Preview("At risk with freezes") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 1500),
        fireRoundExpiresAt: nil,
        streakTier: .gold,
        streakCount: 14,
        isStreakAtRisk: true,
        freezesAvailable: 2,
        perfectWeekActive: false,
        onUseFreezePressed: { },
        accentColor: .cyan
    )
    .padding()
}

#Preview("At risk no freezes") {
    DashboardXPBadgeView(
        levelInfo: XPLevelSystem.levelInfo(forXP: 1500),
        fireRoundExpiresAt: nil,
        streakTier: .silver,
        streakCount: 7,
        isStreakAtRisk: true,
        freezesAvailable: 0,
        perfectWeekActive: false,
        onUseFreezePressed: nil,
        accentColor: .cyan
    )
    .padding()
}
