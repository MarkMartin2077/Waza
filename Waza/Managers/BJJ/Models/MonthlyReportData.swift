import Foundation

// MARK: - MonthlyReportData

struct MonthlyReportData {
    let monthLabel: String
    let dateRange: DateRange

    // Headline stats
    let totalSessions: Int
    let totalHours: Double
    let avgDurationMinutes: Int
    let daysTrained: Int

    // Streak
    let longestStreakInMonth: Int

    // Type breakdown
    let typeBreakdown: [TypeStat]

    // Technique focus
    let topFocusAreas: [(name: String, count: Int)]

    // Mood trends
    let avgPreMood: Double?
    let avgPostMood: Double?
    let bestTrainingDay: (date: Date, postMood: Int)?

    // Gym distribution
    let gymDistribution: [(name: String, count: Int)]

    // Goals
    let goalsCompletedCount: Int

    // Achievements
    let achievementsEarnedCount: Int

    // Challenges (completed in this month's weeks)
    let challengesCompletedCount: Int
    let challengesSweepCount: Int            // weeks where all 3 challenges completed

    // Techniques promoted within this month
    let techniquesPromotedCount: Int

    // XP & Level
    let levelInfo: XPLevelInfo

    // Month-over-month
    let previousMonthSessions: Int
    let previousMonthHours: Double

    var sessionsDelta: Int { totalSessions - previousMonthSessions }
    var hoursDelta: Double { totalHours - previousMonthHours }
    var isFirstMonth: Bool { previousMonthSessions == 0 && previousMonthHours == 0 }

    var totalHoursFormatted: String {
        String(format: "%.1f", totalHours)
    }
}

// MARK: - Mock

extension MonthlyReportData {
    static var mock: MonthlyReportData {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let prevStart = calendar.date(byAdding: .month, value: -1, to: monthStart) else {
            return MonthlyReportData(
                monthLabel: "March 2026",
                dateRange: .lastMonth,
                totalSessions: 0,
                totalHours: 0,
                avgDurationMinutes: 0,
                daysTrained: 0,
                longestStreakInMonth: 0,
                typeBreakdown: [],
                topFocusAreas: [],
                avgPreMood: nil,
                avgPostMood: nil,
                bestTrainingDay: nil,
                gymDistribution: [],
                goalsCompletedCount: 0,
                achievementsEarnedCount: 0,
                challengesCompletedCount: 0,
                challengesSweepCount: 0,
                techniquesPromotedCount: 0,
                levelInfo: XPLevelSystem.levelInfo(forXP: 0),
                previousMonthSessions: 0,
                previousMonthHours: 0
            )
        }
        let prevEnd = calendar.date(byAdding: .second, value: -1, to: monthStart) ?? monthStart
        let range = DateRange(start: prevStart, end: prevEnd)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let label = formatter.string(from: prevStart)

        let bestDay = calendar.date(byAdding: .day, value: 10, to: prevStart) ?? prevStart

        return MonthlyReportData(
            monthLabel: label,
            dateRange: range,
            totalSessions: 12,
            totalHours: 18.5,
            avgDurationMinutes: 92,
            daysTrained: 10,
            longestStreakInMonth: 4,
            typeBreakdown: [
                TypeStat(sessionType: .gi, count: 7, percentage: 0.583),
                TypeStat(sessionType: .noGi, count: 3, percentage: 0.25),
                TypeStat(sessionType: .openMat, count: 2, percentage: 0.167)
            ],
            topFocusAreas: [
                ("Guard Passing", 6),
                ("Back Takes", 4),
                ("Triangles", 3),
                ("Takedowns", 2),
                ("Leg Locks", 1)
            ],
            avgPreMood: 3.4,
            avgPostMood: 4.2,
            bestTrainingDay: (date: bestDay, postMood: 5),
            gymDistribution: [
                ("Gracie Barra", 8),
                ("10th Planet", 4)
            ],
            goalsCompletedCount: 2,
            achievementsEarnedCount: 1,
            challengesCompletedCount: 8,
            challengesSweepCount: 2,
            techniquesPromotedCount: 3,
            levelInfo: XPLevelSystem.levelInfo(forXP: 1200),
            previousMonthSessions: 9,
            previousMonthHours: 13.5
        )
    }

    static var mockEmpty: MonthlyReportData {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let prevStart = calendar.date(byAdding: .month, value: -1, to: monthStart) else {
            return MonthlyReportData(
                monthLabel: "March 2026",
                dateRange: .lastMonth,
                totalSessions: 0,
                totalHours: 0,
                avgDurationMinutes: 0,
                daysTrained: 0,
                longestStreakInMonth: 0,
                typeBreakdown: [],
                topFocusAreas: [],
                avgPreMood: nil,
                avgPostMood: nil,
                bestTrainingDay: nil,
                gymDistribution: [],
                goalsCompletedCount: 0,
                achievementsEarnedCount: 0,
                challengesCompletedCount: 0,
                challengesSweepCount: 0,
                techniquesPromotedCount: 0,
                levelInfo: XPLevelSystem.levelInfo(forXP: 0),
                previousMonthSessions: 0,
                previousMonthHours: 0
            )
        }
        let prevEnd = calendar.date(byAdding: .second, value: -1, to: monthStart) ?? monthStart
        let range = DateRange(start: prevStart, end: prevEnd)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let label = formatter.string(from: prevStart)

        return MonthlyReportData(
            monthLabel: label,
            dateRange: range,
            totalSessions: 0,
            totalHours: 0,
            avgDurationMinutes: 0,
            daysTrained: 0,
            longestStreakInMonth: 0,
            typeBreakdown: [],
            topFocusAreas: [],
            avgPreMood: nil,
            avgPostMood: nil,
            bestTrainingDay: nil,
            gymDistribution: [],
            goalsCompletedCount: 0,
            achievementsEarnedCount: 0,
            challengesCompletedCount: 0,
            challengesSweepCount: 0,
            techniquesPromotedCount: 0,
            levelInfo: XPLevelSystem.levelInfo(forXP: 0),
            previousMonthSessions: 0,
            previousMonthHours: 0
        )
    }
}
