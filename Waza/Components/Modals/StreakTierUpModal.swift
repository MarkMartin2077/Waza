import SwiftUI

struct StreakTierUpModal: View {
    let tier: StreakTier
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var stampScale: Double = 0.6
    @State private var stampOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.wazaPaper.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                HankoView(kanji: "連", size: 96, rotation: 2)
                    .scaleEffect(stampScale)
                    .opacity(stampOpacity)

                VStack(spacing: 10) {
                    Text(headline)
                        .font(.wazaDisplayMedium)
                        .foregroundStyle(Color.wazaInk900)

                    Text(warmStatement)
                        .font(.wazaDisplaySmall)
                        .italic()
                        .foregroundStyle(Color.wazaInk600)

                    Text("STREAK TIER · +\(tier.bonusPercent)% XP BONUS")
                        .font(.wazaLabel)
                        .tracking(1.5)
                        .foregroundStyle(Color.wazaInk500)
                }
                .multilineTextAlignment(.center)
                .opacity(contentOpacity)

                Spacer()

                continueButton
                    .opacity(contentOpacity)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .onAppear(perform: runEntranceAnimation)
        .accessibilityAddTraits(.isModal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Streak bonus upgraded to \(tier.displayName) tier. Plus \(tier.bonusPercent) percent XP bonus.")
    }

    private var headline: String {
        switch tier {
        case .none:    return "On the mat."
        case .bronze:  return "Three days on the mat."
        case .silver:  return "Seven days on the mat."
        case .gold:    return "Fourteen days on the mat."
        case .diamond: return "Thirty days on the mat."
        }
    }

    private var warmStatement: String {
        switch tier {
        case .none:    return "Keep going."
        case .bronze:  return "The habit takes hold."
        case .silver:  return "The ink dries."
        case .gold:    return "Consistency becomes character."
        case .diamond: return "This is who you are now."
        }
    }

    private var continueButton: some View {
        Button {
            onDismiss()
        } label: {
            Text("Continue")
                .font(.wazaBody)
                .fontWeight(.semibold)
                .foregroundStyle(Color.wazaPaperHi)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.wazaAccent, in: RoundedRectangle(cornerRadius: .wazaCornerSmall))
        }
    }

    private func runEntranceAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.05)) {
            stampScale = 1
            stampOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.3).delay(0.28)) {
            contentOpacity = 1
        }
    }
}

#Preview("Bronze — +25%") {
    StreakTierUpModal(tier: .bronze, accentColor: .wazaAccent, onDismiss: { })
}

#Preview("Silver — +50%") {
    StreakTierUpModal(tier: .silver, accentColor: .wazaAccent, onDismiss: { })
}

#Preview("Gold — +75%") {
    StreakTierUpModal(tier: .gold, accentColor: .wazaAccent, onDismiss: { })
}

#Preview("Diamond — +100%") {
    StreakTierUpModal(tier: .diamond, accentColor: .wazaAccent, onDismiss: { })
}
