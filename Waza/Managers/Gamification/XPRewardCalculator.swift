import Foundation

// MARK: - Reward Reason

enum XPRewardReason: String, Sendable, CaseIterable {
    case sessionLogged      = "Session"
    case competitionBonus   = "Competition"
    case fullReflection     = "Reflection"
    case moodTracking       = "Mood"
    case newFocusArea       = "New Focus"
    case checkIn            = "Check-In"
    case streakMilestone    = "Streak"
    case weeklyChallenge    = "Challenge"
    case weeklySweepBonus   = "Sweep"
}

// MARK: - Reward Item

struct XPRewardItem: Sendable, Equatable {
    let reason: XPRewardReason
    let points: Int
}

// MARK: - Reward Result

struct XPRewardResult: Sendable, Equatable {
    let items: [XPRewardItem]

    var totalPoints: Int {
        items.reduce(0) { $0 + $1.points }
    }

    var metadata: [String: GamificationDictionaryValue] {
        var dict: [String: GamificationDictionaryValue] = [
            "source": .string("session"),
            "total": .int(totalPoints)
        ]
        for item in items where item.reason != .sessionLogged {
            dict["bonus_\(item.reason.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))"] = .int(item.points)
        }
        return dict
    }

    var breakdownText: String? {
        let bonuses = items.filter { $0.reason != .sessionLogged }
        guard !bonuses.isEmpty else { return nil }
        return bonuses.map(\.reason.rawValue).joined(separator: " + ")
    }

    static let empty = XPRewardResult(items: [])
}

// MARK: - Calculator

enum XPRewardCalculator {

    // MARK: - Anti-Farming Guards

    /// Minimum session duration (in seconds) to earn XP. Sub-20-minute sessions earn 0 XP
    /// to prevent users from logging fake tiny sessions to farm points.
    static let minimumDurationForXP: TimeInterval = 20 * 60

    /// Daily cap on XP earned from session logging. Prevents log-spamming attacks.
    /// Note: applied externally in SessionLoggingService since the calculator is stateless.
    static let dailySessionXPCap: Int = 100

    // MARK: - Session XP

    /// Calculate total XP reward for logging a session.
    static func calculate(
        params: SessionEntryParams,
        recentFocusAreas: Set<String>
    ) -> XPRewardResult {
        // Sessions shorter than the minimum earn no XP — the mat work has to be real.
        guard params.duration >= minimumDurationForXP else {
            return .empty
        }

        var items: [XPRewardItem] = []

        // Base: 10 XP for any session, 20 for competition
        if params.sessionType == .competition {
            items.append(XPRewardItem(reason: .sessionLogged, points: 10))
            items.append(XPRewardItem(reason: .competitionBonus, points: 10))
        } else {
            items.append(XPRewardItem(reason: .sessionLogged, points: 10))
        }

        // +5 for filling all four reflection fields
        let hasFullReflection = [params.notes, params.whatWorkedWell, params.needsImprovement, params.keyInsights]
            .allSatisfy { ($0 ?? "").trimmingCharacters(in: .whitespaces).isEmpty == false }
        if hasFullReflection {
            items.append(XPRewardItem(reason: .fullReflection, points: 5))
        }

        // +3 for logging both pre and post mood
        if params.preSessionMood != nil && params.postSessionMood != nil {
            items.append(XPRewardItem(reason: .moodTracking, points: 3))
        }

        // +5 for any focus area not seen in last 30 days
        let newAreas = params.focusAreas.filter { !recentFocusAreas.contains($0) }
        if !newAreas.isEmpty {
            items.append(XPRewardItem(reason: .newFocusArea, points: 5))
        }

        return XPRewardResult(items: items)
    }

    // MARK: - Standalone Awards

    static func checkInReward() -> XPRewardResult {
        XPRewardResult(items: [XPRewardItem(reason: .checkIn, points: 5)])
    }

    static func streakMilestoneReward() -> XPRewardResult {
        XPRewardResult(items: [XPRewardItem(reason: .streakMilestone, points: 50)])
    }

    static func weeklyChallengeReward() -> XPRewardResult {
        XPRewardResult(items: [XPRewardItem(reason: .weeklyChallenge, points: 25)])
    }

    static func weeklyChallengeSweepBonus() -> XPRewardResult {
        XPRewardResult(items: [XPRewardItem(reason: .weeklySweepBonus, points: 100)])
    }
}
