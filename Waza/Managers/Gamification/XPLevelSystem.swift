import Foundation

// MARK: - League

enum XPLeague: String, CaseIterable, Sendable {
    case rookie      = "Rookie"
    case scrapper    = "Scrapper"
    case grappler    = "Grappler"
    case contender   = "Contender"
    case adept       = "Adept"
    case ace         = "Ace"
    case vanguard    = "Vanguard"
    // swiftlint:disable:next inclusive_language
    case grandmaster = "Grandmaster" // BJJ title for coral/red belt holders
    case legend      = "Legend"

    var displayName: String { rawValue }
}

// MARK: - Level Info

struct XPLevelInfo: Sendable, Equatable {
    let level: Int
    let league: XPLeague
    let subRank: Int?
    let title: String
    let currentXP: Int
    let xpForCurrentLevel: Int
    let xpForNextLevel: Int?
    let progressToNextLevel: Double
}

// MARK: - XP Level System

enum XPLevelSystem {

    static let maxRankedLevel = 40
    private static let subRanksPerLeague = 5

    // MARK: - Thresholds

    /// XP required to reach a given level. Level 1 = 0 XP.
    static func xpRequired(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return Int(floor(50.0 * pow(Double(level), 1.5)))
    }

    // MARK: - Level from XP

    /// Current level for a given total XP amount.
    static func level(forXP totalXP: Int) -> Int {
        guard totalXP > 0 else { return 1 }
        var lvl = 1
        while xpRequired(forLevel: lvl + 1) <= totalXP {
            lvl += 1
        }
        return lvl
    }

    // MARK: - League & Sub-Rank

    /// League for a given level.
    static func league(forLevel level: Int) -> XPLeague {
        guard level > 0 else { return .rookie }
        if level > maxRankedLevel { return .legend }
        let index = (level - 1) / subRanksPerLeague
        let leagues: [XPLeague] = [.rookie, .scrapper, .grappler, .contender, .adept, .ace, .vanguard, .grandmaster]
        return leagues[min(index, leagues.count - 1)]
    }

    /// Sub-rank (1-5) within the current league. Nil for Legend.
    static func subRank(forLevel level: Int) -> Int? {
        guard level > 0, level <= maxRankedLevel else { return nil }
        return ((level - 1) % subRanksPerLeague) + 1
    }

    /// Display title, e.g. "Adept 3" or "Legend".
    static func title(forLevel level: Int) -> String {
        let league = league(forLevel: level)
        if league == .legend { return league.displayName }
        if let sub = subRank(forLevel: level) {
            return "\(league.displayName) \(sub)"
        }
        return league.displayName
    }

    // MARK: - Progress

    /// Progress toward the next level as 0.0-1.0. Returns 1.0 for Legend.
    static func progressToNextLevel(forXP totalXP: Int) -> Double {
        let lvl = level(forXP: totalXP)
        let currentThreshold = xpRequired(forLevel: lvl)
        guard let nextThreshold = xpRequiredForNextLevel(currentLevel: lvl) else { return 1.0 }
        let range = nextThreshold - currentThreshold
        guard range > 0 else { return 1.0 }
        return Double(totalXP - currentThreshold) / Double(range)
    }

    /// XP required to reach the next level, or nil if Legend.
    static func xpRequiredForNextLevel(currentLevel: Int) -> Int? {
        let next = currentLevel + 1
        return xpRequired(forLevel: next)
    }

    // MARK: - Full Info

    /// Complete level info for a given XP total.
    static func levelInfo(forXP totalXP: Int) -> XPLevelInfo {
        let lvl = level(forXP: totalXP)
        let league = league(forLevel: lvl)
        let sub = subRank(forLevel: lvl)
        let currentThreshold = xpRequired(forLevel: lvl)
        let nextThreshold = xpRequiredForNextLevel(currentLevel: lvl)
        let progress = progressToNextLevel(forXP: totalXP)

        return XPLevelInfo(
            level: lvl,
            league: league,
            subRank: sub,
            title: title(forLevel: lvl),
            currentXP: totalXP,
            xpForCurrentLevel: currentThreshold,
            xpForNextLevel: nextThreshold,
            progressToNextLevel: progress
        )
    }

    /// Whether the user leveled up between two XP totals.
    static func didLevelUp(from oldXP: Int, to newXP: Int) -> Bool {
        level(forXP: newXP) > level(forXP: oldXP)
    }
}
