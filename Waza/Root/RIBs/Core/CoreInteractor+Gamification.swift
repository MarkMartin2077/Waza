import SwiftUI

extension CoreInteractor {

    // MARK: StreakManager

    var currentStreakData: CurrentStreakData {
        streakManager.currentStreakData
    }

    @discardableResult
    func addStreakEvent(metadata: [String: GamificationDictionaryValue] = [:]) async throws -> StreakEvent {
        try await streakManager.addStreakEvent(metadata: metadata)
    }

    func getAllStreakEvents() async throws -> [StreakEvent] {
        try await streakManager.getAllStreakEvents()
    }

    func deleteAllStreakEvents() async throws {
        try await streakManager.deleteAllStreakEvents()
    }

    @discardableResult
    func addStreakFreeze(id: String, dateExpires: Date? = nil) async throws -> StreakFreeze {
        try await streakManager.addStreakFreeze(id: id, dateExpires: dateExpires)
    }

    func useStreakFreezes() async throws {
        try await streakManager.useStreakFreezes()
    }

    func getAllStreakFreezes() async throws -> [StreakFreeze] {
        try await streakManager.getAllStreakFreezes()
    }

    func recalculateStreak() {
        streakManager.recalculateStreak()
    }

    // MARK: ExperiencePointsManager

    var currentExperiencePointsData: CurrentExperiencePointsData {
        xpManager.currentExperiencePointsData
    }

    @discardableResult
    func addExperiencePoints(points: Int, metadata: [String: GamificationDictionaryValue] = [:]) async throws -> ExperiencePointsEvent {
        try await xpManager.addExperiencePoints(points: points, metadata: metadata)
    }

    func getAllExperiencePointsEvents() async throws -> [ExperiencePointsEvent] {
        try await xpManager.getAllExperiencePointsEvents()
    }

    func getAllExperiencePointsEvents(forField field: String, equalTo value: GamificationDictionaryValue) async throws -> [ExperiencePointsEvent] {
        try await xpManager.getAllExperiencePointsEvents(forField: field, equalTo: value)
    }

    func deleteAllExperiencePointsEvents() async throws {
        try await xpManager.deleteAllExperiencePointsEvents()
    }

    func recalculateExperiencePoints() {
        xpManager.recalculateExperiencePoints()
    }

    // MARK: ProgressManager

    func getProgress(id: String) -> Double {
        progressManager.getProgress(id: id)
    }

    func getProgressItem(id: String) -> ProgressItem? {
        progressManager.getProgressItem(id: id)
    }

    func getAllProgress() -> [String: Double] {
        progressManager.getAllProgress()
    }

    func getAllProgressItems() -> [ProgressItem] {
        progressManager.getAllProgressItems()
    }

    func getProgressItems(forMetadataField metadataField: String, equalTo value: GamificationDictionaryValue) -> [ProgressItem] {
        progressManager.getProgressItems(forMetadataField: metadataField, equalTo: value)
    }

    func getMaxProgress(forMetadataField metadataField: String, equalTo value: GamificationDictionaryValue) -> Double {
        progressManager.getMaxProgress(forMetadataField: metadataField, equalTo: value)
    }

    @discardableResult
    func addProgress(id: String, value: Double, metadata: [String: GamificationDictionaryValue]? = nil) async throws -> ProgressItem {
        try await progressManager.addProgress(id: id, value: value, metadata: metadata)
    }

    func deleteProgress(id: String) async throws {
        try await progressManager.deleteProgress(id: id)
    }

    func deleteAllProgress() async throws {
        try await progressManager.deleteAllProgress()
    }

    // MARK: Session + Gamification Combined

    func logSessionWithGamification(_ params: SessionEntryParams) async throws -> BJJSessionModel {
        let session = try createSession(
            date: params.date,
            duration: params.duration,
            sessionType: params.sessionType,
            academy: params.academy,
            instructor: params.instructor,
            focusAreas: params.focusAreas,
            notes: params.notes,
            preSessionMood: params.preSessionMood,
            postSessionMood: params.postSessionMood,
            roundsCount: params.roundsCount,
            whatWorkedWell: params.whatWorkedWell,
            needsImprovement: params.needsImprovement,
            keyInsights: params.keyInsights
        )

        StreakRiskNotificationScheduler.cancel()
        techniqueManager.ensureTechniquesExist(for: params.focusAreas)

        let oldStreakDays = currentStreakData.currentStreak ?? 0
        let result = calculateSessionXP(params: params, streakDays: oldStreakDays)
        let oldXP = currentExperiencePointsData.pointsAllTime ?? 0

        async let streakResult = addStreakEvent()
        async let xpResult = addExperiencePoints(points: result.points, metadata: result.metadata)
        _ = try await (streakResult, xpResult)

        handlePostSessionGamification(
            oldStreakDays: oldStreakDays,
            oldXP: oldXP,
            finalPoints: result.points,
            xpReward: result.reward,
            multiplier: result.multiplier
        )

        return session
    }

    private func calculateSessionXP(params: SessionEntryParams, streakDays: Int) -> SessionXPResult {
        let recent = recentFocusAreas(withinDays: 30)
        let reward = XPRewardCalculator.calculate(params: params, recentFocusAreas: recent)
        let multiplier = XPMultiplierCalculator.calculate(streakDays: streakDays, sessionsLastWeek: sessionsLastWeek())
        let points = XPMultiplierCalculator.apply(multiplier, toBasePoints: reward.totalPoints)

        if multiplier.didActivateFireRound {
            XPMultiplierCalculator.activateFireRound()
            appState.pendingFireRoundActivation = true
        }

        var metadata = reward.metadata
        if multiplier.hasBoost {
            metadata["multiplier"] = .double(multiplier.totalMultiplier)
            if multiplier.isFireRound { metadata["fire_round"] = .bool(true) }
        }

        return SessionXPResult(points: points, metadata: metadata, reward: reward, multiplier: multiplier)
    }

    private func handlePostSessionGamification(
        oldStreakDays: Int,
        oldXP: Int,
        finalPoints: Int,
        xpReward: XPRewardResult,
        multiplier: XPMultiplierResult
    ) {
        let newStreakDays = currentStreakData.currentStreak ?? 0
        if let newTier = XPMultiplierCalculator.streakTierUp(oldDays: oldStreakDays, newDays: newStreakDays) {
            appState.pendingStreakTierUp = newTier
        }

        fireXPToast(
            points: finalPoints,
            oldXP: oldXP,
            breakdownText: xpReward.breakdownText,
            multiplierText: multiplier.displayText,
            isFireRound: multiplier.isFireRound
        )

        let stats = sessionStats
        achievementManager.checkAndAward(
            event: .sessionLogged(totalCount: stats.totalSessions, streakCount: currentStreakData.currentStreak ?? 0),
            sessionStats: stats,
            streakCount: currentStreakData.currentStreak ?? 0
        )

        // Evaluate weekly challenges and award XP for completions
        handleWeeklyChallengeEvaluation()
    }

    private func handleWeeklyChallengeEvaluation() {
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else { return }
        let weekSessions = sessionManager.sessions.filter { $0.date >= weekStart && $0.date < weekEnd }

        // We need a representative session for the evaluate signature; use the most recent this week.
        guard let latestSession = weekSessions.sorted(by: { $0.date > $1.date }).first else { return }

        let completedBefore = challengeManager.completedCount
        let newlyCompleted = challengeManager.evaluate(
            session: latestSession,
            allSessionsThisWeek: weekSessions,
            gyms: classScheduleManager.gyms
        )
        let completedAfter = challengeManager.completedCount

        // Award XP and surface a toast for each newly completed challenge
        for challenge in newlyCompleted {
            let reward = XPRewardCalculator.weeklyChallengeReward()
            Task {
                try? await addExperiencePoints(points: reward.totalPoints, metadata: [
                    "source": .string("weekly_challenge"),
                    "challenge_type": .string(challenge.challengeType.rawValue)
                ])
            }
            appState.pendingChallengeCompletion = challenge.title
        }

        // Award streak freeze when exactly crossing the 2/3 threshold
        if completedBefore < 2, completedAfter >= 2 {
            let weekId = Int(weekStart.timeIntervalSince1970)
            let freezeId = "weekly_challenge_\(weekId)"
            let nextMonday = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)
            Task {
                try? await addStreakFreeze(id: freezeId, dateExpires: nextMonday)
            }
        }

        // Award sweep bonus when exactly crossing the 3/3 threshold
        if completedBefore < 3, completedAfter >= 3 {
            let sweepReward = XPRewardCalculator.weeklyChallengeSweepBonus()
            Task {
                try? await addExperiencePoints(points: sweepReward.totalPoints, metadata: [
                    "source": .string("weekly_challenge_sweep")
                ])
            }
        }
    }

    // MARK: - Check-In XP

    func awardCheckInXP() {
        let reward = XPRewardCalculator.checkInReward()
        let oldXP = currentExperiencePointsData.pointsAllTime ?? 0
        Task {
            try? await addExperiencePoints(points: reward.totalPoints, metadata: [
                "source": .string("check_in")
            ])
            fireXPToast(points: reward.totalPoints, oldXP: oldXP)
        }
    }

    // MARK: - Streak Milestone XP

    func awardStreakMilestoneXP() {
        let reward = XPRewardCalculator.streakMilestoneReward()
        let oldXP = currentExperiencePointsData.pointsAllTime ?? 0
        Task {
            try? await addExperiencePoints(points: reward.totalPoints, metadata: [
                "source": .string("streak_milestone")
            ])
            fireXPToast(points: reward.totalPoints, oldXP: oldXP)
        }
    }

    // MARK: - Helpers

    private func fireXPToast(
        points: Int,
        oldXP: Int,
        breakdownText: String? = nil,
        multiplierText: String? = nil,
        isFireRound: Bool = false
    ) {
        let newXP = oldXP + points
        let leveledUp = XPLevelSystem.didLevelUp(from: oldXP, to: newXP)
        let newLevel: Int? = leveledUp ? XPLevelSystem.level(forXP: newXP) : nil
        let newTitle: String? = newLevel.map { XPLevelSystem.title(forLevel: $0) }
        appState.lastXPGain = XPToastData(
            totalPoints: points,
            leveledUp: leveledUp,
            newLevel: newLevel,
            newTitle: newTitle,
            breakdownText: breakdownText,
            multiplierText: multiplierText,
            isFireRound: isFireRound
        )
    }

    /// Number of sessions logged in the previous calendar week.
    private func sessionsLastWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return 0 }
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart) ?? thisWeekStart
        let lastWeekEnd = thisWeekStart
        return sessionManager.sessions.filter { $0.date >= lastWeekStart && $0.date < lastWeekEnd }.count
    }

    /// Focus areas from sessions in the last N days.
    private func recentFocusAreas(withinDays days: Int) -> Set<String> {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recent = sessionManager.sessions.filter { $0.date >= cutoff }
        return Set(recent.flatMap(\.focusAreas))
    }

}

// MARK: - Session XP Result

private struct SessionXPResult {
    let points: Int
    let metadata: [String: GamificationDictionaryValue]
    let reward: XPRewardResult
    let multiplier: XPMultiplierResult
}
