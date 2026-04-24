import SwiftUI
import SwiftfulUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let onAction: (() -> Void)?
    var kanji: String?

    var body: some View {
        VStack(spacing: 20) {
            hero

            VStack(spacing: 8) {
                Text(title)
                    .font(.wazaDisplaySmall)
                    .foregroundStyle(Color.wazaInk900)
                    .multilineTextAlignment(.center)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.wazaInk500)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 320)

            if let actionTitle, let onAction {
                Text(actionTitle)
                    .font(.wazaBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wazaPaperHi)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: .wazaCornerSmall)
                            .fill(Color.wazaAccent)
                    )
                    .anyButton(.press) {
                        onAction()
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var hero: some View {
        if let kanji {
            HankoView(kanji: kanji, size: 68, rotation: -3)
        } else {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.wazaInk400)
                .frame(width: 68, height: 68)
                .background(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .fill(Color.wazaInk100)
                )
        }
    }
}

#Preview("Hanko - With Action") {
    EmptyStateView(
        icon: "figure.wrestling",
        title: "No Sessions Yet",
        subtitle: "Tap the button to log your first training session.",
        actionTitle: "Log Session",
        onAction: { },
        kanji: "録"
    )
    .background(Color.wazaPaper)
}

#Preview("Hanko - No Action") {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "No Matches",
        subtitle: "Try adjusting your search or filters.",
        actionTitle: nil,
        onAction: nil,
        kanji: "無"
    )
    .background(Color.wazaPaper)
}

#Preview("Symbol fallback") {
    EmptyStateView(
        icon: "trophy",
        title: "No Achievements",
        subtitle: "Keep training to unlock achievements.",
        actionTitle: nil,
        onAction: nil
    )
    .background(Color.wazaPaper)
}
