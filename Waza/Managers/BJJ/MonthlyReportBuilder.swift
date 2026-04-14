import Foundation

/// Assembles a `MonthlyReportData` snapshot by coordinating data from six managers
/// and delegating pure aggregation to `MonthlyReportCalculator`.
///
/// ## Data Freshness
///
/// This builder reads exclusively from the in-memory caches of each manager, which
/// reflect the local SwiftData / FileManager persistence layer. **Local cache is the
/// source of truth for report generation** — we intentionally do not block on remote
/// Firestore sync.
///
/// Consequences:
/// - Reports render instantly on open, even offline.
/// - If a manager is still syncing from remote (fresh install, slow network), the
///   report reflects whatever landed locally so far. Future sessions / achievements
///   merging in won't retroactively update an already-displayed report — the user
///   needs to reopen the screen to see changes.
/// - This is acceptable for monthly reports (historical, not live) but would be wrong
///   for dashboards. If a staleness banner is ever needed, expose an `isDataStale`
///   flag on contributing managers and surface it in the view.
@MainActor
struct MonthlyReportBuilder {
    let sessionManager: SessionManager
    let trainingStatsManager: TrainingStatsManager
    let goalManager: GoalManager
    let achievementManager: AchievementManager
    let challengeManager: ChallengeManager
    let techniqueManager: TechniqueManager
    let xpManager: ExperiencePointsManager

    // swiftlint:disable:next function_body_length
    func build(for dateRange: DateRange) async -> MonthlyReportData {
        let sessions = sessionManager.getSessions(in: dateRange)

        // Previous-month range is derived from the selected month, not hardcoded.
        // Browsing January 2026 must compare against December 2025, not February 2026.
        let calendar = Calendar.current
        let prevStart = calendar.date(byAdding: .month, value: -1, to: dateRange.start) ?? dateRange.start
        let prevEnd = calendar.date(byAdding: .second, value: -1, to: dateRange.start) ?? dateRange.start
        let prevRange = DateRange(start: prevStart, end: prevEnd)
        let prevSessions = sessionManager.getSessions(in: prevRange)

        let totalTime = sessions.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalTime / 3600
        let avgDuration = sessions.isEmpty ? 0 : Int(totalTime / Double(sessions.count) / 60)
        let daysTrained = MonthlyReportCalculator.countDistinctDays(in: sessions)
        let longestStreak = MonthlyReportCalculator.computeLongestStreak(in: sessions, range: dateRange)
        let typeBreakdown = trainingStatsManager.getTypeBreakdown(for: dateRange)
        let topFocusAreas = MonthlyReportCalculator.computeTopFocusAreas(from: sessions)
        let gymDistribution = MonthlyReportCalculator.computeGymDistribution(from: sessions)
        let avgPreMood = MonthlyReportCalculator.averageMood(sessions.compactMap { $0.preSessionMood })
        let avgPostMood = MonthlyReportCalculator.averageMood(sessions.compactMap { $0.postSessionMood })
        let bestDay = MonthlyReportCalculator.bestTrainingDay(from: sessions)
        let goalsCompleted = goalManager.completedGoals.filter {
            guard let date = $0.completedDate else { return false }
            return date >= dateRange.start && date <= dateRange.end
        }.count
        let achievementsEarned = achievementManager.earnedAchievements.filter {
            $0.earnedDate >= dateRange.start && $0.earnedDate <= dateRange.end
        }.count
        let challengesCompleted = MonthlyReportCalculator.countCompletedChallenges(
            from: challengeManager.challenges,
            range: dateRange
        )
        let challengesSweeps = MonthlyReportCalculator.countChallengeSweeps(
            from: challengeManager.challenges,
            range: dateRange
        )
        let techniquesPromoted = MonthlyReportCalculator.countTechniquesPromoted(
            from: techniqueManager.techniques,
            range: dateRange
        )
        let totalXP = xpManager.currentExperiencePointsData.pointsAllTime ?? 0
        let levelInfo = XPLevelSystem.levelInfo(forXP: totalXP)
        let prevTotalTime = prevSessions.reduce(0.0) { $0 + $1.duration }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthLabel = formatter.string(from: dateRange.start)

        return MonthlyReportData(
            monthLabel: monthLabel,
            dateRange: dateRange,
            totalSessions: sessions.count,
            totalHours: totalHours,
            avgDurationMinutes: avgDuration,
            daysTrained: daysTrained,
            longestStreakInMonth: longestStreak,
            typeBreakdown: typeBreakdown,
            topFocusAreas: topFocusAreas,
            avgPreMood: avgPreMood,
            avgPostMood: avgPostMood,
            bestTrainingDay: bestDay,
            gymDistribution: gymDistribution,
            goalsCompletedCount: goalsCompleted,
            achievementsEarnedCount: achievementsEarned,
            challengesCompletedCount: challengesCompleted,
            challengesSweepCount: challengesSweeps,
            techniquesPromotedCount: techniquesPromoted,
            levelInfo: levelInfo,
            previousMonthSessions: prevSessions.count,
            previousMonthHours: prevTotalTime / 3600
        )
    }
}
