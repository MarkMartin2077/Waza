import SwiftUI

struct FireRoundModal: View {
    let onDismiss: () -> Void

    @State private var badgeScale: Double = 0.3
    @State private var backgroundOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var glowScale: Double = 0.8
    @State private var glowOpacity: Double = 0

    private let flameColor = Color.orange

    var body: some View {
        ZStack {
            Color.black
                .opacity(backgroundOpacity * 0.94)
                .ignoresSafeArea()
            flameColor
                .opacity(backgroundOpacity * 0.07)
                .ignoresSafeArea()

            ConfettiView(colors: [.orange, .yellow, .red.opacity(0.8), .white])
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    ForEach(0..<3, id: \.self) { ringIndex in
                        Circle()
                            .stroke(
                                flameColor.opacity(0.3 - Double(ringIndex) * 0.08),
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
                        .fill(flameColor.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(flameColor.opacity(0.85), lineWidth: 2.5)
                        .frame(width: 120, height: 120)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(badgeScale)

                VStack(spacing: 16) {
                    Text("2x XP")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(flameColor.opacity(0.12), in: Capsule())
                        .overlay(Capsule().stroke(flameColor.opacity(0.35), lineWidth: 1))

                    VStack(spacing: 8) {
                        Text("Fire Round")
                            .font(.wazaTitle)
                            .foregroundStyle(.white)

                        Text("All XP is doubled for the next 24 hours!")
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
        .accessibilityLabel("Fire Round activated! All XP is doubled for the next 24 hours. Tap to continue.")
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

#Preview {
    FireRoundModal(onDismiss: { })
}
