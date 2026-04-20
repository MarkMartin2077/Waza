import SwiftUI

extension Font {

    // MARK: - Display (serif — editorial headlines)

    /// Hero display text — screen greeting, report headlines (e.g. "Good morning,")
    static var wazaDisplayLarge: Font { .system(size: 44, weight: .regular, design: .serif) }
    /// Section display — screen intros, card headlines
    static var wazaDisplayMedium: Font { .system(size: 28, weight: .regular, design: .serif) }
    /// Inline display — technique names, row titles
    static var wazaDisplaySmall: Font { .system(size: 20, weight: .regular, design: .serif) }

    // MARK: - Numbers (monospaced — stats & counters)

    /// Giant hero numbers — streak count, session count (light weight, editorial)
    static var wazaHero: Font { .system(size: 72, weight: .light, design: .monospaced) }
    /// Section stat numbers — XP, hours, technique count
    static var wazaStat: Font { .system(size: 44, weight: .light, design: .monospaced) }
    /// Inline numbers — small stats in rows
    static var wazaNumSmall: Font { .system(size: 20, weight: .regular, design: .monospaced) }

    // MARK: - Text (default — body & UI)

    /// Section headers / card titles
    static var wazaTitle: Font { .system(size: 22, weight: .semibold, design: .default) }
    /// Card title (standard row heading)
    static var wazaCardTitle: Font { .system(.subheadline, design: .default, weight: .semibold) }
    /// Card subtitle (supporting description)
    static var wazaCardSubtitle: Font { .system(.caption, design: .default, weight: .regular) }
    /// Body text
    static var wazaBody: Font { .system(size: 15, weight: .regular, design: .default) }

    // MARK: - Labels (monospaced uppercase — section markers)

    /// Uppercase section header ("THIS WEEK", "RECENT SESSIONS")
    static var wazaSectionHeader: Font { .system(.caption2, design: .monospaced, weight: .semibold) }
    /// Small monospaced label — metric captions, timestamps
    static var wazaLabel: Font { .system(size: 10, weight: .medium, design: .monospaced) }
}
