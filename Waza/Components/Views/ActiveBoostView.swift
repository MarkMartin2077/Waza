import SwiftUI

struct ActiveBoostView: View {
    let streakTier: StreakTier
    let fireRoundExpiresAt: Date?
    let perfectWeekActive: Bool

    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var fireRoundActive: Bool {
        guard let expiry = fireRoundExpiresAt else { return false }
        return expiry > now
    }

    private var hasAnyBoost: Bool {
        streakTier != .none || fireRoundActive || perfectWeekActive
    }

    var body: some View {
        if hasAnyBoost {
            VStack(spacing: 8) {
                if fireRoundActive, let expiry = fireRoundExpiresAt {
                    boostRow(
                        icon: "flame.fill",
                        iconColor: .orange,
                        title: "Fire Round — 2x XP",
                        subtitle: timeRemaining(until: expiry)
                    )
                }

                if streakTier != .none {
                    boostRow(
                        icon: "bolt.fill",
                        iconColor: .wazaAccent,
                        title: "\(streakTier.displayName) Streak — +\(streakTier.bonusPercent)%",
                        subtitle: "Active while streak is maintained"
                    )
                }

                if perfectWeekActive {
                    boostRow(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Perfect Week — +25%",
                        subtitle: "Active until Sunday"
                    )
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(fireRoundActive ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .onReceive(timer) { newTime in
                now = newTime
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func boostRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func timeRemaining(until date: Date) -> String {
        let remaining = max(0, date.timeIntervalSince(now))
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s remaining"
        } else {
            return "\(seconds)s remaining"
        }
    }
}

#Preview("Fire Round Active") {
    ActiveBoostView(
        streakTier: .silver,
        fireRoundExpiresAt: Date().addingTimeInterval(3600 * 18),
        perfectWeekActive: false
    )
    .padding()
}

#Preview("All Boosts Active") {
    ActiveBoostView(
        streakTier: .gold,
        fireRoundExpiresAt: Date().addingTimeInterval(3600 * 6),
        perfectWeekActive: true
    )
    .padding()
}

#Preview("Streak Only") {
    ActiveBoostView(
        streakTier: .diamond,
        fireRoundExpiresAt: nil,
        perfectWeekActive: false
    )
    .padding()
}

#Preview("No Boosts") {
    ActiveBoostView(
        streakTier: .none,
        fireRoundExpiresAt: nil,
        perfectWeekActive: false
    )
    .padding()
}
