import SwiftUI

// MARK: - Paper Card Surface

/// Solid paper card surface with a hairline ink border.
/// Replaces `.ultraThinMaterial` for the editorial ink-and-paper aesthetic.
struct WazaCardModifier: ViewModifier {
    var cornerRadius: CGFloat = .wazaCornerStandard

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.wazaPaperHi)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
            )
    }
}

extension View {
    /// Applies the editorial paper card surface with a hairline border.
    /// Use instead of `.ultraThinMaterial` for card-level surfaces.
    func wazaCard(cornerRadius: CGFloat = .wazaCornerStandard) -> some View {
        modifier(WazaCardModifier(cornerRadius: cornerRadius))
    }
}
