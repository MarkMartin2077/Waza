import SwiftUI

struct LevelUpModal: View {
    let level: Int
    let title: String
    let xpGained: Int
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var badgeScale: Double = 0.3
    @State private var backgroundOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var glowScale: Double = 0.8
    @State private var glowOpacity: Double = 0

    private var league: XPLeague {
        XPLevelSystem.league(forLevel: level)
    }

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

                // Level badge
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
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("\(level)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(badgeScale)

                VStack(spacing: 16) {
                    // League chip
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2.weight(.bold))
                        Text(league.displayName.uppercased())
                            .font(.caption.weight(.bold))
                            .tracking(1.5)
                    }
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(accentColor.opacity(0.12), in: Capsule())
                    .overlay(Capsule().stroke(accentColor.opacity(0.35), lineWidth: 1))

                    VStack(spacing: 8) {
                        Text("Level Up")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                            .textCase(.uppercase)
                            .tracking(2)

                        Text(title)
                            .font(.wazaTitle)
                            .foregroundStyle(.white)

                        Text("+\(xpGained) XP earned")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                Spacer()

                VStack(spacing: 16) {
                    if let image = shareImage {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview("Level \(level) — \(title)", image: Image(uiImage: image))
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.15), in: Capsule())
                        }
                    }

                    Text("Tap anywhere to continue")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 36)
            .opacity(contentOpacity)
        }
        .onAppear(perform: runEntranceAnimation)
        .onTapGesture { onDismiss() }
        .accessibilityAddTraits(.isModal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level up! You reached level \(level), \(title). Plus \(xpGained) XP earned. Tap to continue.")
    }

    private var shareImage: UIImage? {
        ShareCardRenderer.render(
            card: ShareCardView(
                cardType: .levelUp(level: level, title: title),
                userName: "",
                accentColor: accentColor
            )
        )
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

#Preview("Rookie 2") {
    LevelUpModal(
        level: 2,
        title: "Rookie 2",
        xpGained: 15,
        accentColor: .cyan,
        onDismiss: { }
    )
}

#Preview("Scrapper 1 — New League") {
    LevelUpModal(
        level: 6,
        title: "Scrapper 1",
        xpGained: 23,
        accentColor: .cyan,
        onDismiss: { }
    )
}

#Preview("Adept 3") {
    LevelUpModal(
        level: 23,
        title: "Adept 3",
        xpGained: 33,
        accentColor: .cyan,
        onDismiss: { }
    )
}

#Preview("Legend") {
    LevelUpModal(
        level: 41,
        title: "Legend",
        xpGained: 50,
        accentColor: .cyan,
        onDismiss: { }
    )
}
