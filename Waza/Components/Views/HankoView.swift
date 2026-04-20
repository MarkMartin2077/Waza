import SwiftUI

/// A kanji stamp — the core brand element of Waza's editorial design.
///
/// Represents a "hanko" (判子), the personal seal used in Japanese culture.
/// In Waza, each training session earns a stamp. The kanji character identifies
/// the session type; the color indicates earned status or category.
struct HankoView: View {
    let kanji: String
    var size: CGFloat = 40
    var rotation: Double = 0
    var color: Color = .wazaAccent
    var inkColor: Color = .wazaPaperHi

    var body: some View {
        Text(kanji)
            .font(.system(size: size * 0.5))
            .foregroundStyle(inkColor)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .shadow(color: color.opacity(0.08), radius: 1, y: 1)
            )
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Previews

#Preview("Tatami Red") {
    HankoView(kanji: "技", size: 44, rotation: -2)
        .padding()
}

#Preview("Dark Ink") {
    HankoView(kanji: "道", size: 44, rotation: 3, color: .wazaInk900)
        .padding()
}

#Preview("Belt Blue") {
    HankoView(kanji: "青", size: 40, rotation: 12, color: .wazaBeltBlue)
        .padding()
}

#Preview("Grid") {
    HStack(spacing: 12) {
        HankoView(kanji: "技", size: 36, rotation: -2)
        HankoView(kanji: "体", size: 36, rotation: 1)
        HankoView(kanji: "道", size: 36, rotation: -3, color: .wazaInk900)
        HankoView(kanji: "練", size: 36, rotation: 2)
        HankoView(kanji: "試", size: 36, rotation: -1)
        HankoView(kanji: "師", size: 36, rotation: 3, color: .wazaInk900)
    }
    .padding()
}
