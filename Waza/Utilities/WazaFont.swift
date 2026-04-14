import SwiftUI

extension Font {
    /// Giant hero numbers (streak count, session count)
    static var wazaHero: Font { .system(size: 72, weight: .black, design: .rounded) }
    /// Section stat numbers
    static var wazaStat: Font { .system(size: 44, weight: .black, design: .rounded) }
    /// Section headers / card titles
    static var wazaTitle: Font { .system(size: 22, weight: .bold, design: .rounded) }
    /// Card title (standard row heading, e.g. "Achievements", "Monthly Report")
    static var wazaCardTitle: Font { .system(.subheadline, design: .default, weight: .semibold) }
    /// Card subtitle (supporting description under a card title)
    static var wazaCardSubtitle: Font { .system(.caption, design: .default, weight: .regular) }
    /// Uppercase section header ("THIS WEEK", "RECENT SESSIONS")
    static var wazaSectionHeader: Font { .system(.caption, design: .default, weight: .semibold) }
    /// Small caps / metric labels
    static var wazaLabel: Font { .system(size: 12, weight: .semibold, design: .rounded) }
}
