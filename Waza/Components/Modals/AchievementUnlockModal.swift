import SwiftUI

struct AchievementUnlockModal: View {
    let achievementId: AchievementId
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var badgeScale: Double = 0.3
    @State private var backgroundOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var glowScale: Double = 0.8
    @State private var glowOpacity: Double = 0

    private var rarityColor: Color { achievementId.rarity.color }

    var body: some View {
        ZStack {
            // Background — near-black with subtle belt tint
            Color.black
                .opacity(backgroundOpacity * 0.94)
                .ignoresSafeArea()
            accentColor
                .opacity(backgroundOpacity * 0.07)
                .ignoresSafeArea()

            // Confetti burst
            ConfettiView(colors: confettiColors)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Badge
                ZStack {
                    // Rarity glow rings
                    ForEach(0..<3, id: \.self) { ringIndex in
                        Circle()
                            .stroke(
                                rarityColor.opacity(0.25 - Double(ringIndex) * 0.07),
                                lineWidth: 1.5
                            )
                            .frame(
                                width: 126 + CGFloat(ringIndex) * 20,
                                height: 126 + CGFloat(ringIndex) * 20
                            )
                            .scaleEffect(glowScale)
                            .opacity(glowOpacity)
                    }

                    // Badge circle
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(rarityColor.opacity(0.85), lineWidth: 2.5)
                        .frame(width: 120, height: 120)

                    Image(systemName: achievementId.iconName)
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(badgeScale)

                VStack(spacing: 16) {
                    // Rarity chip
                    HStack(spacing: 6) {
                        Image(systemName: achievementId.rarity.symbolName)
                            .font(.caption2.weight(.bold))
                        Text(achievementId.rarity.displayName.uppercased())
                            .font(.caption.weight(.bold))
                            .tracking(1.5)
                    }
                    .foregroundStyle(rarityColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(rarityColor.opacity(0.12), in: Capsule())
                    .overlay(Capsule().stroke(rarityColor.opacity(0.35), lineWidth: 1))

                    // Text stack
                    VStack(spacing: 8) {
                        Text("Achievement Unlocked")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                            .textCase(.uppercase)
                            .tracking(2)

                        Text(achievementId.displayName)
                            .font(.wazaTitle)
                            .foregroundStyle(.white)

                        Text(achievementId.achievementDescription)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 36)
            .opacity(contentOpacity)
        }
        .onAppear(perform: runEntranceAnimation)
        .onTapGesture { onDismiss() }
    }

    // MARK: - Helpers

    private var confettiColors: [Color] {
        [rarityColor, rarityColor.opacity(0.7), .white, accentColor.opacity(0.8)]
    }

    private func runEntranceAnimation() {
        withAnimation(.easeIn(duration: 0.25)) {
            backgroundOpacity = 1
        }
        withAnimation(.spring(response: 0.48, dampingFraction: 0.62).delay(0.08)) {
            badgeScale = 1
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.12)) {
            glowScale = 1.1
            glowOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.3).delay(0.18)) {
            contentOpacity = 1
        }
    }
}

// MARK: - Previews

#Preview("Common — First Roll") {
    AchievementUnlockModal(
        achievementId: .firstSession,
        accentColor: Color(hex: "5A6A7A"),
        onDismiss: { }
    )
}

#Preview("Rare — 7-Day Streak") {
    AchievementUnlockModal(
        achievementId: .sevenDayStreak,
        accentColor: Color(hex: "1E56A0"),
        onDismiss: { }
    )
}

#Preview("Epic — On a Roll") {
    AchievementUnlockModal(
        achievementId: .fourWeekConsistency,
        accentColor: Color(hex: "7B2D8B"),
        onDismiss: { }
    )
}

#Preview("Legendary — 30-Day Streak") {
    AchievementUnlockModal(
        achievementId: .thirtyDayStreak,
        accentColor: Color(hex: "1E56A0"),
        onDismiss: { }
    )
}
