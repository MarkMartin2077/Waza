import SwiftUI

struct FireRoundModal: View {
    let onDismiss: () -> Void

    @State private var stampScale: Double = 0.6
    @State private var stampOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.wazaPaper.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                HankoView(kanji: "倍", size: 96, rotation: -2)
                    .scaleEffect(stampScale)
                    .opacity(stampOpacity)

                VStack(spacing: 10) {
                    Text("Double time.")
                        .font(.wazaDisplayMedium)
                        .foregroundStyle(Color.wazaInk900)

                    Text("For the next 24 hours, every mark counts twice.")
                        .font(.wazaDisplaySmall)
                        .italic()
                        .foregroundStyle(Color.wazaInk600)

                    Text("2× XP · 24 HOURS")
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
        .accessibilityLabel("Double time. For the next 24 hours, every mark counts twice. 2 times XP for 24 hours.")
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

#Preview {
    FireRoundModal(onDismiss: { })
}
