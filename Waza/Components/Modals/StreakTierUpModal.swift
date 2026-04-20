import SwiftUI

struct StreakTierUpModal: View {
    let tier: StreakTier
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var badgeScale: Double = 0.3
    @State private var backgroundOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var glowScale: Double = 0.8
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black
                .opacity(backgroundOpacity * 0.94)
                .ignoresSafeArea()
            accentColor
                .opacity(backgroundOpacity * 0.07)
                .ignoresSafeArea()

            ConfettiView(colors: [accentColor, accentColor.opacity(0.7), .white, .yellow.opacity(0.8)])
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    ForEach(0..<3, id: \.self) { ringIndex in
                        Circle()
                            .stroke(
                                accentColor.opacity(0.25 - Double(ringIndex) * 0.07),
                                lineWidth: 1.5
                            )
                            .frame(
                                width: 126 + CGFloat(ringIndex) * 20,
                                height: 126 + CGFloat(ringIndex) * 20
                            )
                            .scaleEffect(glowScale)
                            .opacity(glowOpacity)
                    }

                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(accentColor.opacity(0.85), lineWidth: 2.5)
                        .frame(width: 120, height: 120)

                    VStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(accentColor)
                        Text("+\(tier.bonusPercent)%")
                            .font(.wazaDisplayMedium)
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(badgeScale)

                VStack(spacing: 16) {
                    Text("\(tier.displayName) Streak".uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(accentColor.opacity(0.12), in: Capsule())
                        .overlay(Capsule().stroke(accentColor.opacity(0.35), lineWidth: 1))

                    VStack(spacing: 8) {
                        Text("Streak Bonus Upgraded")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                            .textCase(.uppercase)
                            .tracking(2)

                        Text("\(tier.displayName) Tier — +\(tier.bonusPercent)% XP")
                            .font(.wazaTitle)
                            .foregroundStyle(.white)

                        Text("Keep your streak alive to maintain this bonus!")
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
        .accessibilityAddTraits(.isModal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Streak bonus upgraded to \(tier.displayName) tier, plus \(tier.bonusPercent) percent XP. Tap to continue.")
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

#Preview("Bronze — +25%") {
    StreakTierUpModal(tier: .bronze, accentColor: .cyan, onDismiss: { })
}

#Preview("Silver — +50%") {
    StreakTierUpModal(tier: .silver, accentColor: .cyan, onDismiss: { })
}

#Preview("Gold — +75%") {
    StreakTierUpModal(tier: .gold, accentColor: .cyan, onDismiss: { })
}

#Preview("Diamond — +100%") {
    StreakTierUpModal(tier: .diamond, accentColor: .cyan, onDismiss: { })
}
