import SwiftUI

struct AchievementRowView: View {
    let achievementId: AchievementId
    let isEarned: Bool
    let earnedDate: Date?
    let progressHint: String?
    let onTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            iconCircle
            textInfo
            Spacer(minLength: 0)
            statusIndicator
        }
        .opacity(isEarned ? 1 : 0.6)
        .anyButton(.press) {
            onTap?()
        }
    }

    private var iconCircle: some View {
        let rarityColor = achievementId.rarity.color
        return ZStack {
            Circle()
                .fill(isEarned ? rarityColor.opacity(0.15) : Color(.systemGray5))
                .frame(width: 52, height: 52)
                .overlay(
                    Circle().stroke(
                        isEarned ? rarityColor.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
                )
            Image(systemName: isEarned ? achievementId.iconName : "lock.fill")
                .font(.title3)
                .foregroundStyle(isEarned ? rarityColor : Color(.systemGray3))
        }
    }

    private var textInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(achievementId.displayName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(achievementId.achievementDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            rarityChip
        }
    }

    @ViewBuilder
    private var rarityChip: some View {
        let rarityColor = achievementId.rarity.color

        // For locked achievements with a progress hint, show the hint instead of the
        // rarity label — it tells the user *how to unlock*, which is more actionable
        // and keeps the list from feeling dead.
        if !isEarned, let progressHint {
            Label(progressHint, systemImage: "target")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.wazaAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.wazaAccent.opacity(0.12), in: Capsule())
        } else {
            Label(achievementId.rarity.displayName, systemImage: achievementId.rarity.symbolName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(isEarned ? rarityColor : Color.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    (isEarned ? rarityColor : Color.secondary).opacity(0.12),
                    in: Capsule()
                )
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        if isEarned, let earnedDate {
            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
                Text(earnedDate.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .frame(width: 60)
        }
    }
}

// MARK: - Previews

#Preview("Earned — Legendary") {
    AchievementRowView(
        achievementId: .hundredSessions,
        isEarned: true,
        earnedDate: Date(),
        progressHint: nil,
        onTap: nil
    )
    .padding()
}

#Preview("Earned — Rare") {
    AchievementRowView(
        achievementId: .sevenDayStreak,
        isEarned: true,
        earnedDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
        progressHint: nil,
        onTap: nil
    )
    .padding()
}

#Preview("Locked") {
    AchievementRowView(
        achievementId: .thirtyDayStreak,
        isEarned: false,
        earnedDate: nil,
        progressHint: "22 days away",
        onTap: nil
    )
    .padding()
}

#Preview("List") {
    List {
        ForEach(AchievementId.allCases, id: \.self) { achievementId in
            AchievementRowView(
                achievementId: achievementId,
                isEarned: (AchievementId.allCases.firstIndex(of: achievementId) ?? 99) < 5,
                earnedDate: (AchievementId.allCases.firstIndex(of: achievementId) ?? 99) < 5 ? Date() : nil,
                progressHint: nil,
                onTap: nil
            )
        }
    }
}
