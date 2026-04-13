import Foundation

// MARK: - Multiplier Reason

enum XPMultiplierReason: String, Sendable, Equatable {
    case streak         = "Streak"
    case perfectWeek    = "Perfect Week"
    case fireRound      = "Fire Round"
}

// MARK: - Multiplier Component

struct XPMultiplierComponent: Sendable, Equatable {
    let reason: XPMultiplierReason
    let bonus: Double
}

// MARK: - Multiplier Result

struct XPMultiplierResult: Sendable, Equatable {
    let components: [XPMultiplierComponent]
    /// Whether a new fire round was just activated (not an existing one).
    let didActivateFireRound: Bool

    /// Combined multiplier before fire round (e.g., 1.75).
    var baseMultiplier: Double {
        1.0 + components.filter { $0.reason != .fireRound }.reduce(0) { $0 + $1.bonus }
    }

    /// Final multiplier including fire round (e.g., 3.5 if fire round active).
    var totalMultiplier: Double {
        let base = baseMultiplier
        return isFireRound ? base * 2.0 : base
    }

    var isFireRound: Bool {
        components.contains { $0.reason == .fireRound }
    }

    var hasBoost: Bool {
        totalMultiplier > 1.0
    }

    /// Short display text for the toast, e.g. "1.5x Streak" or "3.5x Fire Round + Streak"
    var displayText: String? {
        guard hasBoost else { return nil }
        let names = components.map(\.reason.rawValue)
        let formatted = String(format: "%.1fx", totalMultiplier)
            .replacingOccurrences(of: ".0x", with: "x")
        return "\(formatted) \(names.joined(separator: " + "))"
    }

    static let none = XPMultiplierResult(components: [], didActivateFireRound: false)
}

// MARK: - Streak Tier

enum StreakTier: Int, Sendable, Equatable, Comparable {
    case none = 0
    case bronze = 3    // +25%
    case silver = 7    // +50%
    case gold = 14     // +75%
    case diamond = 30  // +100%

    var displayName: String {
        switch self {
        case .none:    return "None"
        case .bronze:  return "Bronze"
        case .silver:  return "Silver"
        case .gold:    return "Gold"
        case .diamond: return "Diamond"
        }
    }

    var bonusPercent: Int {
        switch self {
        case .none:    return 0
        case .bronze:  return 25
        case .silver:  return 50
        case .gold:    return 75
        case .diamond: return 100
        }
    }

    static func tier(forDays days: Int) -> StreakTier {
        switch days {
        case 30...: return .diamond
        case 14...: return .gold
        case 7...:  return .silver
        case 3...:  return .bronze
        default:    return .none
        }
    }

    static func < (lhs: StreakTier, rhs: StreakTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Calculator

enum XPMultiplierCalculator {

    static let fireRoundChance: Double = 0.15
    static let fireRoundDuration: TimeInterval = 24 * 60 * 60
    static let perfectWeekTarget: Int = 3

    private static let fireRoundExpiryKey = "waza_fire_round_expires_at"

    // MARK: - Streak Thresholds

    /// Streak bonus based on consecutive training days.
    static func streakBonus(forDays days: Int) -> Double {
        Double(StreakTier.tier(forDays: days).bonusPercent) / 100.0
    }

    // MARK: - Fire Round Persistence

    /// The expiry date of the active fire round, or nil if none.
    static func fireRoundExpiresAt() -> Date? {
        let interval = UserDefaults.standard.double(forKey: fireRoundExpiryKey)
        guard interval > 0 else { return nil }
        let date = Date(timeIntervalSince1970: interval)
        return date > Date() ? date : nil
    }

    /// Whether a fire round is currently active.
    static func isFireRoundActive() -> Bool {
        fireRoundExpiresAt() != nil
    }

    /// Activate a new 24-hour fire round.
    static func activateFireRound() {
        let expiry = Date().addingTimeInterval(fireRoundDuration)
        UserDefaults.standard.set(expiry.timeIntervalSince1970, forKey: fireRoundExpiryKey)
    }

    /// Clear any active fire round.
    static func clearFireRound() {
        UserDefaults.standard.removeObject(forKey: fireRoundExpiryKey)
    }

    // MARK: - Streak Tier Detection

    /// Returns the new tier if the streak just crossed a threshold, nil otherwise.
    static func streakTierUp(oldDays: Int, newDays: Int) -> StreakTier? {
        let oldTier = StreakTier.tier(forDays: oldDays)
        let newTier = StreakTier.tier(forDays: newDays)
        return newTier > oldTier ? newTier : nil
    }

    // MARK: - Debug Overrides

    #if DEBUG
    private static let devStreakDaysKey = "dev_xp_override_streak_days"
    private static let devForceFireRoundKey = "dev_xp_force_fire_round"
    private static let devForcePerfectWeekKey = "dev_xp_force_perfect_week"

    static var devOverrideStreakDays: Int {
        get { UserDefaults.standard.integer(forKey: devStreakDaysKey) }
        set { UserDefaults.standard.set(newValue, forKey: devStreakDaysKey) }
    }

    static var devForceFireRound: Bool {
        get { UserDefaults.standard.bool(forKey: devForceFireRoundKey) }
        set { UserDefaults.standard.set(newValue, forKey: devForceFireRoundKey) }
    }

    static var devForcePerfectWeek: Bool {
        get { UserDefaults.standard.bool(forKey: devForcePerfectWeekKey) }
        set { UserDefaults.standard.set(newValue, forKey: devForcePerfectWeekKey) }
    }
    #endif

    // MARK: - Calculate

    /// Compute the XP multiplier for a session.
    /// - Parameters:
    ///   - streakDays: Current consecutive streak count.
    ///   - sessionsLastWeek: Number of sessions logged in the previous calendar week.
    ///   - randomRoll: A value in 0..<1 for fire round determination. Inject for testability.
    ///   - checkActiveFireRound: Whether to check for existing fire round boost. Set false in tests.
    static func calculate(
        streakDays: Int,
        sessionsLastWeek: Int,
        randomRoll: Double = Double.random(in: 0..<1),
        checkActiveFireRound: Bool = true
    ) -> XPMultiplierResult {
        var components: [XPMultiplierComponent] = []
        var didActivateNew = false

        // Apply debug overrides if active
        var effectiveStreakDays = streakDays
        var effectiveSessionsLastWeek = sessionsLastWeek
        var effectiveRoll = randomRoll

        #if DEBUG
        if devOverrideStreakDays > 0 { effectiveStreakDays = devOverrideStreakDays }
        if devForcePerfectWeek { effectiveSessionsLastWeek = max(effectiveSessionsLastWeek, perfectWeekTarget) }
        if devForceFireRound { effectiveRoll = 0.0 }
        #endif

        // Streak multiplier
        let streak = streakBonus(forDays: effectiveStreakDays)
        if streak > 0 {
            components.append(XPMultiplierComponent(reason: .streak, bonus: streak))
        }

        // Perfect week (hit target last week)
        if effectiveSessionsLastWeek >= perfectWeekTarget {
            components.append(XPMultiplierComponent(reason: .perfectWeek, bonus: 0.25))
        }

        // Fire round — check active boost first, then roll for new
        if checkActiveFireRound && isFireRoundActive() {
            components.append(XPMultiplierComponent(reason: .fireRound, bonus: 0))
        } else if effectiveRoll < fireRoundChance {
            components.append(XPMultiplierComponent(reason: .fireRound, bonus: 0))
            didActivateNew = true
        }

        return XPMultiplierResult(components: components, didActivateFireRound: didActivateNew)
    }

    // MARK: - Apply

    /// Apply a multiplier result to a base point total.
    static func apply(_ multiplier: XPMultiplierResult, toBasePoints base: Int) -> Int {
        guard multiplier.hasBoost else { return base }
        return Int(round(Double(base) * multiplier.totalMultiplier))
    }
}
