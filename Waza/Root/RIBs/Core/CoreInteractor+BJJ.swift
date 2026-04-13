import SwiftUI

extension CoreInteractor {

    // MARK: BJJ Sessions

    var recentSessions: [BJJSessionModel] {
        sessionManager.getRecentSessions(limit: 5)
    }

    var allSessions: [BJJSessionModel] {
        sessionManager.sessions
    }

    var sessionStats: SessionStats {
        sessionManager.getSessionStats()
    }

    @discardableResult
    func createSession(
        date: Date = Date(),
        duration: TimeInterval = 5400,
        sessionType: SessionType = .gi,
        academy: String? = nil,
        instructor: String? = nil,
        focusAreas: [String] = [],
        notes: String? = nil,
        preSessionMood: Int? = nil,
        postSessionMood: Int? = nil,
        roundsCount: Int = 0,
        whatWorkedWell: String? = nil,
        needsImprovement: String? = nil,
        keyInsights: String? = nil
    ) throws -> BJJSessionModel {
        try sessionManager.createSession(
            date: date,
            duration: duration,
            sessionType: sessionType,
            academy: academy,
            instructor: instructor,
            focusAreas: focusAreas,
            notes: notes,
            preSessionMood: preSessionMood,
            postSessionMood: postSessionMood,
            roundsCount: roundsCount,
            whatWorkedWell: whatWorkedWell,
            needsImprovement: needsImprovement,
            keyInsights: keyInsights
        )
    }

    func updateSession(_ session: BJJSessionModel) throws {
        try sessionManager.updateSession(session)
    }

    func deleteSession(_ session: BJJSessionModel) throws {
        try sessionManager.deleteSession(session)
    }

    // MARK: BJJ Belt

    var currentBelt: BeltRecordModel? {
        beltManager.currentBelt
    }

    var currentBeltEnum: BJJBelt {
        beltManager.currentBeltEnum
    }

    var beltHistory: [BeltRecordModel] {
        beltManager.beltHistory
    }

    @discardableResult
    func addBeltPromotion(
        belt: BJJBelt,
        stripes: Int = 0,
        date: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) throws -> BeltRecordModel {
        try beltManager.addPromotion(belt: belt, stripes: stripes, date: date, academy: academy, notes: notes)
    }

    func setInitialBelt(
        belt: BJJBelt,
        stripes: Int = 0,
        date: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) throws {
        try beltManager.addPromotion(belt: belt, stripes: stripes, date: date, academy: academy, notes: notes)
        // No achievement check — this is an initial belt setup, not a promotion
    }

    func estimatedTimeToNextBelt() -> String? {
        beltManager.estimatedTimeToNextBelt(sessionsPerWeek: Double(sessionStats.thisWeekSessions))
    }

    // MARK: BJJ Goals

    var activeGoals: [TrainingGoalModel] {
        goalManager.activeGoals
    }

    var completedGoals: [TrainingGoalModel] {
        goalManager.completedGoals
    }

    @discardableResult
    func createGoal(
        title: String,
        description: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil
    ) throws -> TrainingGoalModel {
        try goalManager.createGoal(title: title, description: description, goalType: goalType, deadline: deadline)
    }

    func updateGoalProgress(goalId: String, progress: Double) throws {
        try goalManager.updateProgress(goalId: goalId, progress: progress)
    }

    func completeGoal(goalId: String) throws {
        try goalManager.completeGoal(goalId: goalId)
        achievementManager.checkAndAward(
            event: .goalCompleted(goalId: goalId),
            sessionStats: sessionStats,
            streakCount: currentStreakData.currentStreak ?? 0
        )
    }

    func updateGoal(_ goal: TrainingGoalModel) throws {
        try goalManager.updateGoal(goal)
    }

    func deleteGoal(_ goal: TrainingGoalModel) throws {
        try goalManager.deleteGoal(goal)
    }

    @discardableResult
    func createMetricGoal(metric: GoalMetric, targetValue: Double, focusArea: String? = nil) throws -> TrainingGoalModel {
        try goalManager.createMetricGoal(metric: metric, targetValue: targetValue, focusArea: focusArea)
    }

    func computeProgress(for goal: TrainingGoalModel) -> Double {
        goalManager.computeProgress(for: goal, sessions: sessionManager.sessions)
    }

    func currentValue(for goal: TrainingGoalModel) -> Double {
        goalManager.currentValue(for: goal, sessions: sessionManager.sessions)
    }

    var distinctFocusAreas: [String] {
        Array(Set(sessionManager.sessions.flatMap { $0.focusAreas })).sorted()
    }

    // MARK: BJJ Achievements

    var earnedAchievements: [AchievementEarnedModel] {
        achievementManager.earnedAchievements
    }

    func isAchievementEarned(_ id: AchievementId) -> Bool {
        achievementManager.isEarned(id)
    }

    var lastUnlockedAchievement: AchievementId? {
        achievementManager.lastUnlockedAchievement
    }

    func consumeUnlockedAchievement() {
        achievementManager.consumeUnlockedAchievement()
    }

    var xpAppState: AppState {
        appState
    }

    // MARK: BJJ Techniques

    var allTechniques: [TechniqueModel] {
        techniqueManager.techniques
    }

    func updateTechnique(_ technique: TechniqueModel) throws {
        try techniqueManager.updateTechnique(technique)
    }

    func deleteTechnique(_ technique: TechniqueModel) throws {
        try techniqueManager.deleteTechnique(technique)
    }

    func createTechnique(name: String, category: TechniqueCategory) {
        try? techniqueManager.createTechnique(name: name, category: category)
    }

    func ensureTechniquesExist(for focusAreas: [String]) {
        techniqueManager.ensureTechniquesExist(for: focusAreas)
    }

    // MARK: AI Insights

    var isAIAvailable: Bool {
        aiInsightsManager.isAvailable
    }

    var aiUnavailabilityMessage: String {
        aiInsightsManager.unavailabilityMessage
    }

    func streamWeeklySummary(sessions: [BJJSessionModel], belt: BJJBelt) -> AsyncThrowingStream<String, Error> {
        aiInsightsManager.streamWeeklySummary(sessions: sessions, belt: belt)
    }

    func generateInsights(sessions: [BJJSessionModel], belt: BJJBelt) async throws -> [AITrainingInsight] {
        try await aiInsightsManager.generateInsights(sessions: sessions, belt: belt)
    }

    // MARK: Widget Data

    func updateWidgetData(_ data: WazaWidgetData) {
        WidgetDataStore.shared.update(data)
    }

    // MARK: Training Stats

    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot {
        trainingStatsManager.getTrainingSnapshot(period: period)
    }

    func getTypeBreakdown() -> [TypeStat] {
        trainingStatsManager.getTypeBreakdown()
    }

    func getTypeBreakdown(for period: DateRange) -> [TypeStat] {
        trainingStatsManager.getTypeBreakdown(for: period)
    }

    // MARK: Monthly Report

    func getMonthlyReportData(for dateRange: DateRange) async -> MonthlyReportData {
        let sessions = sessionManager.getSessions(in: dateRange)
        let prevRange = DateRange.calendarMonth(monthsAgo: 2)
        let prevSessions = sessionManager.getSessions(in: prevRange)

        let totalTime = sessions.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalTime / 3600
        let avgDuration = sessions.isEmpty ? 0 : Int(totalTime / Double(sessions.count) / 60)
        let daysTrained = countDistinctDays(in: sessions)
        let longestStreak = computeLongestStreak(in: sessions, range: dateRange)
        let typeBreakdown = trainingStatsManager.getTypeBreakdown(for: dateRange)
        let topFocusAreas = computeTopFocusAreas(from: sessions)
        let gymDistribution = computeGymDistribution(from: sessions)
        let avgPreMood = averageMood(sessions.compactMap { $0.preSessionMood })
        let avgPostMood = averageMood(sessions.compactMap { $0.postSessionMood })
        let bestDay = bestTrainingDay(from: sessions)
        let goalsCompleted = goalManager.completedGoals.filter {
            guard let date = $0.completedDate else { return false }
            return date >= dateRange.start && date <= dateRange.end
        }.count
        let achievementsEarned = achievementManager.earnedAchievements.filter {
            $0.earnedDate >= dateRange.start && $0.earnedDate <= dateRange.end
        }.count
        let totalXP = currentExperiencePointsData.pointsAllTime ?? 0
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
            levelInfo: levelInfo,
            previousMonthSessions: prevSessions.count,
            previousMonthHours: prevTotalTime / 3600
        )
    }

    // MARK: - Monthly Report Helpers

    private func countDistinctDays(in sessions: [BJJSessionModel]) -> Int {
        let calendar = Calendar.current
        return Set(sessions.map { calendar.startOfDay(for: $0.date) }).count
    }

    private func computeLongestStreak(in sessions: [BJJSessionModel], range: DateRange) -> Int {
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
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return longestRun
    }

    private func computeTopFocusAreas(from sessions: [BJJSessionModel]) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions {
            for area in session.focusAreas {
                counts[area, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
            .prefix(5)
            .map { (name: $0.key, count: $0.value) }
    }

    private func computeGymDistribution(from sessions: [BJJSessionModel]) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions {
            guard let academy = session.academy, !academy.isEmpty else { continue }
            counts[academy, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
            .map { (name: $0.key, count: $0.value) }
    }

    private func averageMood(_ moods: [Int]) -> Double? {
        guard !moods.isEmpty else { return nil }
        return Double(moods.reduce(0, +)) / Double(moods.count)
    }

    private func bestTrainingDay(from sessions: [BJJSessionModel]) -> (date: Date, postMood: Int)? {
        sessions
            .compactMap { session -> (date: Date, postMood: Int)? in
                guard let mood = session.postSessionMood else { return nil }
                return (date: session.date, postMood: mood)
            }
            .max { $0.postMood < $1.postMood }
    }

}
