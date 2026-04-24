import SwiftUI

struct AchievementUnlockModal: View {
    let achievementId: AchievementId
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

                HankoView(kanji: stampKanji, size: 96, rotation: -2)
                    .scaleEffect(stampScale)
                    .opacity(stampOpacity)

                VStack(spacing: 10) {
                    Text("Marked.")
                        .font(.wazaDisplayMedium)
                        .foregroundStyle(Color.wazaInk900)

                    Text(achievementId.displayName)
                        .font(.wazaDisplaySmall)
                        .italic()
                        .foregroundStyle(Color.wazaInk600)

                    Text(achievementId.achievementDescription.uppercased())
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
        .accessibilityLabel("Marked. \(achievementId.displayName). \(achievementId.achievementDescription).")
    }

    /// Semantic kanji keyed to each achievement. Defaults to 印 (mark/stamp).
    private var stampKanji: String {
        switch achievementId {
        case .firstSession:               return "初"   // first
        case .tenSessions:                return "十"   // ten
        case .fiftySessions:              return "五"   // fifty
        case .hundredSessions:            return "百"   // hundred
        case .threeDayStreak:             return "連"   // consecutive
        case .sevenDayStreak:             return "連"
        case .thirtyDayStreak:            return "連"
        case .firstGoalCompleted:         return "達"   // attain/reach
        case .firstClassCheckedIn:        return "入"   // enter
        case .fiveClassAttendance:        return "皆"   // all/every
        case .twentyFiveClassAttendance:  return "道"   // path/way
        case .perfectWeek:                return "全"   // complete/perfect
        case .fourWeekConsistency:        return "継"   // continue/sustain
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

// MARK: - Previews

#Preview("Common — First Roll") {
    AchievementUnlockModal(
        achievementId: .firstSession,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}

#Preview("Rare — 7-Day Streak") {
    AchievementUnlockModal(
        achievementId: .sevenDayStreak,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}

#Preview("Epic — On a Roll") {
    AchievementUnlockModal(
        achievementId: .fourWeekConsistency,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}

#Preview("Legendary — 30-Day Streak") {
    AchievementUnlockModal(
        achievementId: .thirtyDayStreak,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}
