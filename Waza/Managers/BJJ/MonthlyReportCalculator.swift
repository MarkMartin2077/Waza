import Foundation

// MARK: - Monthly Report Calculator
//
// Pure static enum — zero external dependencies. All input passed as parameters.
// Mirrors the ChallengeGenerator pattern: extracting aggregation logic into a
// pure type makes the full pipeline unit-testable without spinning up CoreInteractor
// or mocking 6+ managers.

enum MonthlyReportCalculator {

    // MARK: - Distinct Training Days

    static func countDistinctDays(in sessions: [BJJSessionModel]) -> Int {
        let calendar = Calendar.current
        return Set(sessions.map { calendar.startOfDay(for: $0.date) }).count
    }

    // MARK: - Longest Streak Within Range

    /// Computes the longest run of consecutive calendar days the user trained,
    /// looking only at days inside `range`.
    static func computeLongestStreak(in sessions: [BJJSessionModel], range: DateRange) -> Int {
        let calendar = Calendar.current
        let trainedDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        guard !trainedDays.isEmpty else { return 0 }

        var current = calendar.startOfDay(for: range.start)
        let end = calendar.startOfDay(for: range.end)
        var longestRun = 0
        var currentRun = 0

        while current <= end {
            if trainedDays.contains(current) {
                currentRun += 1
                longestRun = max(longestRun, currentRun)
            } else {
                currentRun = 0
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return longestRun
    }

    // MARK: - Top Focus Areas

    static func computeTopFocusAreas(
        from sessions: [BJJSessionModel],
        limit: Int = 5
    ) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions {
            for area in session.focusAreas {
                counts[area, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (name: $0.key, count: $0.value) }
    }

    // MARK: - Gym Distribution

    /// Returns gym counts sorted descending. Sessions with nil or empty academy are skipped.
    static func computeGymDistribution(from sessions: [BJJSessionModel]) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions {
            guard let academy = session.academy, !academy.isEmpty else { continue }
            counts[academy, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
            .map { (name: $0.key, count: $0.value) }
    }

    // MARK: - Mood

    static func averageMood(_ moods: [Int]) -> Double? {
        guard !moods.isEmpty else { return nil }
        return Double(moods.reduce(0, +)) / Double(moods.count)
    }

    static func bestTrainingDay(from sessions: [BJJSessionModel]) -> (date: Date, postMood: Int)? {
        sessions
            .compactMap { session -> (date: Date, postMood: Int)? in
                guard let mood = session.postSessionMood else { return nil }
                return (date: session.date, postMood: mood)
            }
            .max { $0.postMood < $1.postMood }
    }

    // MARK: - Challenges

    /// Counts challenges that were completed within the range.
    static func countCompletedChallenges(
        from challenges: [WeeklyChallengeModel],
        range: DateRange
    ) -> Int {
        challenges.filter { challenge in
            guard challenge.isCompleted, let completed = challenge.completedDate else { return false }
            return completed >= range.start && completed <= range.end
        }.count
    }

    /// Counts weeks within the range where ALL challenges for that week completed.
    /// A sweep requires the week to have >= 3 challenges and all of them completed.
    static func countChallengeSweeps(
        from challenges: [WeeklyChallengeModel],
        range: DateRange
    ) -> Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: challenges) { calendar.startOfDay(for: $0.weekStartDate) }

        return grouped.filter { weekStart, weekChallenges in
            // Week's start date must be within the range
            guard weekStart >= calendar.startOfDay(for: range.start),
                  weekStart <= calendar.startOfDay(for: range.end) else { return false }
            guard weekChallenges.count >= 3 else { return false }
            return weekChallenges.allSatisfy { $0.isCompleted }
        }.count
    }

    // MARK: - Techniques

    /// Counts techniques whose `lastStageChangeDate` falls within the range.
    static func countTechniquesPromoted(
        from techniques: [TechniqueModel],
        range: DateRange
    ) -> Int {
        techniques.filter { technique in
            guard let changed = technique.lastStageChangeDate else { return false }
            return changed >= range.start && changed <= range.end
        }.count
    }
}
