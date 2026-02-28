import SwiftUI

struct AchievementUnlockModal: View {
    let achievementId: AchievementId
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var badgeScale: Double = 0.3
    @State private var backgroundOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            accentColor
                .opacity(backgroundOpacity)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: achievementId.iconName)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 120, height: 120)
                    .background(.white.opacity(0.2), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.45), lineWidth: 2))
                    .scaleEffect(badgeScale)

                VStack(spacing: 10) {
                    Text("Achievement Unlocked")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.75))
                        .textCase(.uppercase)
                        .tracking(2)

                    Text(achievementId.displayName)
                        .font(.wazaTitle)
                        .foregroundStyle(.white)

                    Text(achievementId.achievementDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                backgroundOpacity = 0.92
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1)) {
                badgeScale = 1
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                contentOpacity = 1
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
}

#Preview {
    AchievementUnlockModal(
        achievementId: .sevenDayStreak,
        accentColor: .blue,
        onDismiss: { }
    )
}

#Preview("Belt promotion") {
    AchievementUnlockModal(
        achievementId: .firstBeltPromotion,
        accentColor: .purple,
        onDismiss: { }
    )
}
