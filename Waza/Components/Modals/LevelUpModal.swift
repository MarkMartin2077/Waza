import SwiftUI

struct LevelUpModal: View {
    let level: Int
    let title: String
    let xpGained: Int
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var stampScale: Double = 0.6
    @State private var stampOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    private var league: XPLeague {
        XPLevelSystem.league(forLevel: level)
    }

    var body: some View {
        ZStack {
            Color.wazaPaper.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                HankoView(kanji: "段", size: 96, rotation: -3)
                    .scaleEffect(stampScale)
                    .opacity(stampOpacity)

                VStack(spacing: 10) {
                    Text("Promotion.")
                        .font(.wazaDisplayMedium)
                        .foregroundStyle(Color.wazaInk900)

                    Text(title)
                        .font(.wazaDisplaySmall)
                        .italic()
                        .foregroundStyle(Color.wazaInk600)

                    Text("LEVEL \(level) · \(xpGained) XP EARNED")
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
        .accessibilityLabel("Promotion. You reached level \(level), \(title). \(xpGained) XP earned.")
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

#Preview("Rookie 2") {
    LevelUpModal(
        level: 2,
        title: "Rookie 2",
        xpGained: 15,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}

#Preview("Scrapper 1 — New League") {
    LevelUpModal(
        level: 6,
        title: "Scrapper 1",
        xpGained: 23,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}

#Preview("Adept 3") {
    LevelUpModal(
        level: 23,
        title: "Adept 3",
        xpGained: 33,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}

#Preview("Legend") {
    LevelUpModal(
        level: 41,
        title: "Legend",
        xpGained: 50,
        accentColor: .wazaAccent,
        onDismiss: { }
    )
}
