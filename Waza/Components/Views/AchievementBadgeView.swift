import SwiftUI

struct AchievementBadgeView: View {
    let achievementId: AchievementId
    let isEarned: Bool
    let accentColor: Color?
    let onTap: (() -> Void)?

    private var resolvedAccent: Color { accentColor ?? .accentColor }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: isEarned ? achievementId.iconName : "lock.fill")
                .font(.title3)
                .foregroundStyle(isEarned ? resolvedAccent : .secondary)
                .frame(width: 52, height: 52)
                .background(
                    isEarned ? resolvedAccent.opacity(0.15) : Color(.systemGray5),
                    in: Circle()
                )
                .overlay(
                    Circle()
                        .stroke(isEarned ? resolvedAccent.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
                .opacity(isEarned ? 1 : 0.45)

            Text(achievementId.displayName)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(isEarned ? .primary : .secondary)
                .opacity(isEarned ? 1 : 0.5)
        }
        .anyButton {
            onTap?()
        }
    }
}

#Preview("Earned") {
    AchievementBadgeView(
        achievementId: .sevenDayStreak,
        isEarned: true,
        accentColor: .blue,
        onTap: nil
    )
    .padding()
}

#Preview("Locked") {
    AchievementBadgeView(
        achievementId: .hundredSessions,
        isEarned: false,
        accentColor: .blue,
        onTap: nil
    )
    .padding()
}

#Preview("Grid") {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 16) {
        ForEach(AchievementId.allCases, id: \.self) { achievementId in
            AchievementBadgeView(
                achievementId: achievementId,
                isEarned: (AchievementId.allCases.firstIndex(of: achievementId) ?? 99) < 4,
                accentColor: .purple,
                onTap: nil
            )
        }
    }
    .padding()
}
