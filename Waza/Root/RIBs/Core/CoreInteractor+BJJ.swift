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

}
