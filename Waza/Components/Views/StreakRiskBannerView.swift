import SwiftUI

struct StreakRiskBannerView: View {
    let currentStreak: Int
    let streakTier: StreakTier
    let freezesAvailable: Int
    let onUseFreezePressed: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Streak at risk!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitleText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if freezesAvailable > 0, let onUseFreezePressed {
                Text("Use Freeze")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange, in: Capsule())
                    .anyButton(.press) {
                        onUseFreezePressed()
                    }
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your \(currentStreak) day streak is at risk. Train today to keep it alive.")
    }

    private var subtitleText: String {
        var text = "Your \(currentStreak)-day streak"
        if streakTier != .none {
            text += " (\(streakTier.displayName) +\(streakTier.bonusPercent)%)"
        }
        text += " expires today."
        if freezesAvailable > 0 {
            text += " \(freezesAvailable) freeze\(freezesAvailable == 1 ? "" : "s") available."
        }
        return text
    }
}

#Preview("At risk — no freezes") {
    StreakRiskBannerView(
        currentStreak: 7,
        streakTier: .silver,
        freezesAvailable: 0,
        onUseFreezePressed: nil
    )
    .padding()
}

#Preview("At risk — has freezes") {
    StreakRiskBannerView(
        currentStreak: 14,
        streakTier: .gold,
        freezesAvailable: 2,
        onUseFreezePressed: { }
    )
    .padding()
}

#Preview("Short streak — no tier") {
    StreakRiskBannerView(
        currentStreak: 2,
        streakTier: .none,
        freezesAvailable: 0,
        onUseFreezePressed: nil
    )
    .padding()
}
