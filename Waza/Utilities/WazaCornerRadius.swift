import CoreGraphics

/// Standardized corner-radius ladder for Waza. Three values, clear semantics.
///
/// - `small`: chips, pills, compact status badges, inline tips
/// - `standard`: card-level surfaces (challenge cards, stat tiles, recent session rows)
/// - `hero`: featured / identity-establishing surfaces (monthly report hero, level-up celebrations)
///
/// Use these tokens for any new surface; grep-and-replace existing literals over time.
extension CGFloat {
    static let wazaCornerSmall: CGFloat = 12
    static let wazaCornerStandard: CGFloat = 16
    static let wazaCornerHero: CGFloat = 20
}
