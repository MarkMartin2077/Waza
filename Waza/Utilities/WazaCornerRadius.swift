import CoreGraphics

/// Standardized corner-radius ladder for Waza. Tight radii for editorial feel.
///
/// - `small`: chips, pills, compact status badges, hanko stamps
/// - `standard`: card-level surfaces (challenge cards, stat tiles, session rows)
/// - `hero`: featured / identity-establishing surfaces (monthly report, level-up)
///
/// Use these tokens for any new surface; grep-and-replace existing literals over time.
extension CGFloat {
    static let wazaCornerSmall: CGFloat = 4
    static let wazaCornerStandard: CGFloat = 8
    static let wazaCornerHero: CGFloat = 12
}
