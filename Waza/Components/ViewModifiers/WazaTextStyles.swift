import SwiftUI

// MARK: - Waza Label Style

/// Monospaced uppercase label — the editorial section marker used throughout the design.
/// Applies: monospaced font, uppercase, wide letter spacing, ink500 color.
struct WazaLabelStyleModifier: ViewModifier {
    var color: Color = .wazaInk500

    func body(content: Content) -> some View {
        content
            .font(.wazaLabel)
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(color)
    }
}

extension View {
    /// Applies the editorial label style: monospaced, uppercase, tracked, muted ink color.
    func wazaLabelStyle(color: Color = .wazaInk500) -> some View {
        modifier(WazaLabelStyleModifier(color: color))
    }
}

// MARK: - Waza Display Style

/// Serif display text style for editorial headlines.
struct WazaDisplayStyleModifier: ViewModifier {
    var size: WazaDisplaySize = .medium
    var italic: Bool = false
    var color: Color = .wazaInk900

    func body(content: Content) -> some View {
        content
            .font(size.font)
            .italic(italic)
            .foregroundStyle(color)
    }
}

enum WazaDisplaySize {
    case large, medium, small

    var font: Font {
        switch self {
        case .large: return .wazaDisplayLarge
        case .medium: return .wazaDisplayMedium
        case .small: return .wazaDisplaySmall
        }
    }
}

extension View {
    /// Applies the editorial display style: serif, optional italic, ink900 default.
    func wazaDisplayStyle(size: WazaDisplaySize = .medium, italic: Bool = false, color: Color = .wazaInk900) -> some View {
        modifier(WazaDisplayStyleModifier(size: size, italic: italic, color: color))
    }
}

// MARK: - Waza Number Style

/// Monospaced light-weight number style for stats and counters.
struct WazaNumStyleModifier: ViewModifier {
    var color: Color = .wazaInk900

    func body(content: Content) -> some View {
        content
            .monospacedDigit()
            .foregroundStyle(color)
    }
}

extension View {
    /// Applies monospaced digit rendering with the given color.
    func wazaNumStyle(color: Color = .wazaInk900) -> some View {
        modifier(WazaNumStyleModifier(color: color))
    }
}
