import Testing
import Foundation
@testable import Waza

// MARK: - Helpers

private func session(
    daysAgo: Int = 0,
    duration: TimeInterval = 3600,
    academy: String? = nil,
    focusAreas: [String] = [],
    preMood: Int? = nil,
    postMood: Int? = nil
) -> BJJSessionModel {
    let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    return BJJSessionModel(
        date: date,
        duration: duration,
        sessionType: .gi,
        academy: academy,
        focusAreas: focusAreas,
        preSessionMood: preMood,
        postSessionMood: postMood
    )
}

// MARK: - Distinct Days

@Suite("MonthlyReportCalculator - Distinct Days")
struct MonthlyReportDistinctDaysTests {

    @Test("Empty sessions yields zero distinct days")
    func emptyReturnsZero() {
        #expect(MonthlyReportCalculator.countDistinctDays(in: []) == 0)
    }

    @Test("Multiple sessions on the same day collapse to one day")
    func sameDayCollapses() {
        let sessions = [session(daysAgo: 0), session(daysAgo: 0), session(daysAgo: 0)]
        #expect(MonthlyReportCalculator.countDistinctDays(in: sessions) == 1)
    }

    @Test("Sessions across distinct days count each day once")
    func distinctDaysCounted() {
        let sessions = [session(daysAgo: 0), session(daysAgo: 1), session(daysAgo: 3)]
        #expect(MonthlyReportCalculator.countDistinctDays(in: sessions) == 3)
    }
}

// MARK: - Longest Streak

@Suite("MonthlyReportCalculator - Longest Streak")
struct MonthlyReportStreakTests {

    @Test("Empty session list yields zero streak")
    func emptyYieldsZero() {
        let range = DateRange.lastDays(30)
        #expect(MonthlyReportCalculator.computeLongestStreak(in: [], range: range) == 0)
    }

    @Test("Single training day yields streak of 1")
    func singleDayStreakIsOne() {
        let sessions = [session(daysAgo: 5)]
        let range = DateRange.lastDays(30)
        #expect(MonthlyReportCalculator.computeLongestStreak(in: sessions, range: range) == 1)
    }

    @Test("Three consecutive training days yields streak of 3")
    func consecutiveDaysCounted() {
        let sessions = [session(daysAgo: 2), session(daysAgo: 3), session(daysAgo: 4)]
        let range = DateRange.lastDays(30)
        #expect(MonthlyReportCalculator.computeLongestStreak(in: sessions, range: range) == 3)
    }

    @Test("Gaps break the streak and the longest run wins")
    func longestRunWins() {
        // Days ago 1, 2, 3 (run of 3) and 10, 11 (run of 2)
        let sessions = [
            session(daysAgo: 1), session(daysAgo: 2), session(daysAgo: 3),
            session(daysAgo: 10), session(daysAgo: 11)
        ]
        let range = DateRange.lastDays(30)
        #expect(MonthlyReportCalculator.computeLongestStreak(in: sessions, range: range) == 3)
    }

    @Test("Multiple sessions on the same day still count as one streak day")
    func sameDayNotDoubleCounted() {
        let sessions = [session(daysAgo: 1), session(daysAgo: 1), session(daysAgo: 2)]
        let range = DateRange.lastDays(30)
        #expect(MonthlyReportCalculator.computeLongestStreak(in: sessions, range: range) == 2)
    }
}

// MARK: - Top Focus Areas

@Suite("MonthlyReportCalculator - Focus Areas")
struct MonthlyReportFocusAreasTests {

    @Test("Empty sessions yields empty focus areas")
    func emptySessions() {
        #expect(MonthlyReportCalculator.computeTopFocusAreas(from: []).isEmpty)
    }

    @Test("Sessions with no focus areas yield empty result")
    func sessionsWithoutAreas() {
        let sessions = [session(daysAgo: 0), session(daysAgo: 1)]
        #expect(MonthlyReportCalculator.computeTopFocusAreas(from: sessions).isEmpty)
    }

    @Test("Focus areas are counted and sorted descending")
    func countsAndSorts() {
        let sessions = [
            session(daysAgo: 0, focusAreas: ["Guard", "Guard", "Pass"]),
            session(daysAgo: 1, focusAreas: ["Guard", "Sweeps"]),
            session(daysAgo: 2, focusAreas: ["Pass"])
        ]

        let result = MonthlyReportCalculator.computeTopFocusAreas(from: sessions)

        // Guard: 3, Pass: 2, Sweeps: 1
        #expect(result.first?.name == "Guard")
        #expect(result.first?.count == 3)
        #expect(result[1].name == "Pass")
        #expect(result[1].count == 2)
    }

    @Test("Result is capped at default limit of 5")
    func cappedAtFive() {
        let sessions = [
            session(daysAgo: 0, focusAreas: ["A", "B", "C", "D", "E", "F", "G"])
        ]

        let result = MonthlyReportCalculator.computeTopFocusAreas(from: sessions)

        #expect(result.count == 5)
    }

    @Test("Custom limit respected")
    func customLimit() {
        let sessions = [session(daysAgo: 0, focusAreas: ["A", "B", "C", "D"])]
        let result = MonthlyReportCalculator.computeTopFocusAreas(from: sessions, limit: 2)
        #expect(result.count == 2)
    }
}

// MARK: - Gym Distribution

@Suite("MonthlyReportCalculator - Gym Distribution")
struct MonthlyReportGymTests {

    @Test("Empty sessions yields empty distribution")
    func emptySessions() {
        #expect(MonthlyReportCalculator.computeGymDistribution(from: []).isEmpty)
    }

    @Test("Sessions with nil academy are skipped")
    func nilAcademiesSkipped() {
        let sessions = [
            session(daysAgo: 0, academy: nil),
            session(daysAgo: 1, academy: "Gracie Barra"),
            session(daysAgo: 2, academy: nil)
        ]

        let result = MonthlyReportCalculator.computeGymDistribution(from: sessions)

        #expect(result.count == 1)
        #expect(result.first?.name == "Gracie Barra")
        #expect(result.first?.count == 1)
    }

    @Test("Sessions with empty-string academy are skipped")
    func emptyAcademiesSkipped() {
        let sessions = [
            session(daysAgo: 0, academy: ""),
            session(daysAgo: 1, academy: "Real Gym")
        ]

        let result = MonthlyReportCalculator.computeGymDistribution(from: sessions)

        #expect(result.count == 1)
        #expect(result.first?.name == "Real Gym")
    }

    @Test("Counts are sorted descending")
    func sortedDescending() {
        let sessions = [
            session(daysAgo: 0, academy: "A"),
            session(daysAgo: 1, academy: "B"),
            session(daysAgo: 2, academy: "B"),
            session(daysAgo: 3, academy: "B"),
            session(daysAgo: 4, academy: "A"),
            session(daysAgo: 5, academy: "C")
        ]

        let result = MonthlyReportCalculator.computeGymDistribution(from: sessions)

        #expect(result[0].name == "B")
        #expect(result[0].count == 3)
        #expect(result[1].name == "A")
        #expect(result[1].count == 2)
        #expect(result[2].name == "C")
        #expect(result[2].count == 1)
    }
}

// MARK: - Mood

@Suite("MonthlyReportCalculator - Mood")
struct MonthlyReportMoodTests {

    @Test("Empty moods yields nil")
    func emptyYieldsNil() {
        #expect(MonthlyReportCalculator.averageMood([]) == nil)
    }

    @Test("Single mood averages to itself")
    func singleMood() {
        #expect(MonthlyReportCalculator.averageMood([4]) == 4.0)
    }

    @Test("Average of multiple moods is correct")
    func multiMoodAverage() {
        let avg = MonthlyReportCalculator.averageMood([2, 4, 6])
        #expect(avg == 4.0)
    }

    @Test("bestTrainingDay returns nil when no session has a post-mood")
    func noPostMoodReturnsNil() {
        let sessions = [session(daysAgo: 0, postMood: nil), session(daysAgo: 1, postMood: nil)]
        #expect(MonthlyReportCalculator.bestTrainingDay(from: sessions) == nil)
    }

    @Test("bestTrainingDay picks the session with the highest post-mood")
    func highestPostMoodWins() {
        let sessions = [
            session(daysAgo: 0, postMood: 3),
            session(daysAgo: 1, postMood: 5),
            session(daysAgo: 2, postMood: 4)
        ]

        let best = MonthlyReportCalculator.bestTrainingDay(from: sessions)

        #expect(best?.postMood == 5)
    }

    @Test("bestTrainingDay ignores sessions with nil post-mood")
    func nilPostMoodIgnored() {
        let sessions = [
            session(daysAgo: 0, postMood: nil),
            session(daysAgo: 1, postMood: 3),
            session(daysAgo: 2, postMood: nil)
        ]

        let best = MonthlyReportCalculator.bestTrainingDay(from: sessions)

        #expect(best?.postMood == 3)
    }
}

// MARK: - MonthlyReportData Computed Properties

@Suite("MonthlyReportData - Computed Properties")
struct MonthlyReportDataComputedTests {

    @Test("sessionsDelta is current minus previous")
    func sessionsDelta() {
        let data = makeReport(totalSessions: 10, previousMonthSessions: 7)
        #expect(data.sessionsDelta == 3)
    }

    @Test("hoursDelta can be negative")
    func hoursDeltaNegative() {
        let data = makeReport(totalHours: 5.5, previousMonthHours: 8.0)
        #expect(data.hoursDelta == -2.5)
    }

    @Test("isFirstMonth is true only when previous month has zero sessions AND zero hours")
    func isFirstMonthFlag() {
        let first = makeReport(previousMonthSessions: 0, previousMonthHours: 0)
        #expect(first.isFirstMonth)

        let notFirst = makeReport(previousMonthSessions: 3, previousMonthHours: 0)
        #expect(notFirst.isFirstMonth == false)
    }

    @Test("totalHoursFormatted renders to one decimal")
    func hoursFormatting() {
        let data = makeReport(totalHours: 12.3456)
        #expect(data.totalHoursFormatted == "12.3")
    }

    private func makeReport(
        totalSessions: Int = 0,
        totalHours: Double = 0,
        previousMonthSessions: Int = 0,
        previousMonthHours: Double = 0
    ) -> MonthlyReportData {
        MonthlyReportData(
            monthLabel: "Test",
            dateRange: .lastMonth,
            totalSessions: totalSessions,
            totalHours: totalHours,
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
            previousMonthSessions: previousMonthSessions,
            previousMonthHours: previousMonthHours
        )
    }
}

// MARK: - Challenge Aggregation

@Suite("MonthlyReportCalculator - Challenges")
struct MonthlyReportChallengeTests {

    private func monthRange() -> DateRange {
        let start = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return DateRange(start: start, end: Date())
    }

    private func challenge(
        weekStart: Date,
        type: ChallengeType = .trainXTimes,
        isCompleted: Bool,
        completedDate: Date? = nil
    ) -> WeeklyChallengeModel {
        WeeklyChallengeModel(
            weekStartDate: weekStart,
            challengeType: type,
            title: "t",
            targetValue: 1,
            currentValue: isCompleted ? 1 : 0,
            isCompleted: isCompleted,
            completedDate: completedDate
        )
    }

    @Test("Empty challenges yields zero completed")
    func emptyChallenges() {
        #expect(MonthlyReportCalculator.countCompletedChallenges(from: [], range: monthRange()) == 0)
    }

    @Test("Only challenges with completedDate inside range are counted")
    func completedDateFilter() {
        let range = monthRange()
        let inside = range.start.addingTimeInterval(3600)
        let outside = range.start.addingTimeInterval(-3600 * 24 * 40)
        let weekStart = range.start

        let challenges = [
            challenge(weekStart: weekStart, isCompleted: true, completedDate: inside),
            challenge(weekStart: weekStart, isCompleted: true, completedDate: outside),
            challenge(weekStart: weekStart, isCompleted: false)
        ]

        #expect(MonthlyReportCalculator.countCompletedChallenges(from: challenges, range: range) == 1)
    }

    @Test("Sweep count: a week with all 3 complete counts as one sweep")
    func sweepWithThreeCompleted() {
        let range = monthRange()
        let weekStart = range.start.addingTimeInterval(3600 * 24)   // a day after range start
        let completed = weekStart.addingTimeInterval(3600)

        let challenges = (0..<3).map { _ in
            challenge(weekStart: weekStart, isCompleted: true, completedDate: completed)
        }

        #expect(MonthlyReportCalculator.countChallengeSweeps(from: challenges, range: range) == 1)
    }

    @Test("Sweep count: a week with only 2 of 3 complete does not count")
    func partialWeekDoesNotSweep() {
        let range = monthRange()
        let weekStart = range.start.addingTimeInterval(3600 * 24)

        let challenges = [
            challenge(weekStart: weekStart, isCompleted: true, completedDate: weekStart),
            challenge(weekStart: weekStart, isCompleted: true, completedDate: weekStart),
            challenge(weekStart: weekStart, isCompleted: false)
        ]

        #expect(MonthlyReportCalculator.countChallengeSweeps(from: challenges, range: range) == 0)
    }

    @Test("Sweep count: a week with only 2 challenges total cannot sweep")
    func twoChallengesCannotSweep() {
        let range = monthRange()
        let weekStart = range.start.addingTimeInterval(3600 * 24)

        let challenges = [
            challenge(weekStart: weekStart, isCompleted: true, completedDate: weekStart),
            challenge(weekStart: weekStart, isCompleted: true, completedDate: weekStart)
        ]

        #expect(MonthlyReportCalculator.countChallengeSweeps(from: challenges, range: range) == 0)
    }

    @Test("Sweep count: multiple fully-completed weeks all count")
    func multipleSweepWeeks() {
        let range = monthRange()
        let week1 = range.start.addingTimeInterval(3600 * 24 * 3)
        let week2 = range.start.addingTimeInterval(3600 * 24 * 10)

        var challenges: [WeeklyChallengeModel] = []
        for start in [week1, week2] {
            for _ in 0..<3 {
                challenges.append(challenge(weekStart: start, isCompleted: true, completedDate: start))
            }
        }

        #expect(MonthlyReportCalculator.countChallengeSweeps(from: challenges, range: range) == 2)
    }

    @Test("Sweep count ignores weeks whose weekStartDate is outside the range")
    func outOfRangeWeekNotCounted() {
        let range = monthRange()
        let outOfRange = range.start.addingTimeInterval(-3600 * 24 * 40)

        let challenges = (0..<3).map { _ in
            challenge(weekStart: outOfRange, isCompleted: true, completedDate: outOfRange)
        }

        #expect(MonthlyReportCalculator.countChallengeSweeps(from: challenges, range: range) == 0)
    }
}

// MARK: - Technique Aggregation

@Suite("MonthlyReportCalculator - Techniques")
struct MonthlyReportTechniqueTests {

    private func monthRange() -> DateRange {
        let start = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return DateRange(start: start, end: Date())
    }

    @Test("No techniques with a stage change yields zero")
    func noChangesZero() {
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .applying),
            TechniqueModel(name: "Armbar", stage: .drilling)
        ]

        #expect(MonthlyReportCalculator.countTechniquesPromoted(from: techniques, range: monthRange()) == 0)
    }

    @Test("Techniques promoted within the range are counted")
    func promotedInRange() {
        let range = monthRange()
        let inRange = range.start.addingTimeInterval(3600 * 24)
        let outOfRange = range.start.addingTimeInterval(-3600 * 24 * 40)

        let techniques = [
            TechniqueModel(name: "A", lastStageChangeDate: inRange),
            TechniqueModel(name: "B", lastStageChangeDate: inRange),
            TechniqueModel(name: "C", lastStageChangeDate: outOfRange)
        ]

        #expect(MonthlyReportCalculator.countTechniquesPromoted(from: techniques, range: range) == 2)
    }

    @Test("Technique without lastStageChangeDate is ignored")
    func nilDateIgnored() {
        let techniques = [TechniqueModel(name: "A", lastStageChangeDate: nil)]
        #expect(MonthlyReportCalculator.countTechniquesPromoted(from: techniques, range: monthRange()) == 0)
    }
}
