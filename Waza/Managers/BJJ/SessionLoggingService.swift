import Foundation
import SwiftUI

/// Encapsulates the multi-manager orchestration that happens when a session is logged:
/// session creation, XP + streak updates, achievement checks, and weekly challenge evaluation.
@MainActor
struct SessionLoggingService {
    let appState: AppState
    let sessionManager: SessionManager
    let techniqueManager: TechniqueManager
    let streakManager: StreakManager
    let xpManager: ExperiencePointsManager
    let achievementManager: AchievementManager
    let challengeManager: ChallengeManager
    let classScheduleManager: ClassScheduleManager
    let logManager: LogManager
    /// Callback to refresh Home Screen widget data. Injected by CoreInteractor so the
    /// service can push a widget update after session save without knowing about BeltManager.
    let refreshWidgetData: @MainActor () -> Void

    static let freezeCap = 3

    // MARK: - Public Entry Points

    func logSession(params: SessionEntryParams) async throws -> BJJSessionModel {
        let session = try sessionManager.createSession(
            date: params.date,
            duration: params.duration,
            sessionType: params.sessionType,
            academy: params.academy,
            instructor: params.instructor,
            focusAreas: params.focusAreas,
            techniquesWorked: params.techniquesWorked,
            notes: params.notes,
            preSessionMood: params.preSessionMood,
            postSessionMood: params.postSessionMood,
            roundsCount: params.roundsCount,
            whatWorkedWell: params.whatWorkedWell,
            needsImprovement: params.needsImprovement,
            keyInsights: params.keyInsights
        )

        StreakRiskNotificationScheduler.cancel()
        techniqueManager.ensureTechniquesExist(for: params.focusAreas + params.techniquesWorked)

        let oldStreakDays = streakManager.currentStreakData.currentStreak ?? 0
        let result = calculateSessionXP(params: params, streakDays: oldStreakDays)
        let oldXP = xpManager.currentExperiencePointsData.pointsAllTime ?? 0

        async let streakResult = streakManager.addStreakEvent(metadata: [:])
        async let xpResult = xpManager.addExperiencePoints(points: result.points, metadata: result.metadata)
        _ = try await (streakResult, xpResult)
        recordSessionXPEarnedToday(result.points)

        handlePostSessionGamification(
            oldStreakDays: oldStreakDays,
            oldXP: oldXP,
            finalPoints: result.points,
            xpReward: result.reward,
            multiplier: result.multiplier
        )

        checkTechniquePromotions(techniquesWorked: params.focusAreas + params.techniquesWorked)

        // First-session starter freeze — gives brand-new users a single safety net before
        // they're even engaged with weekly challenges.
        if sessionManager.getSessionStats().totalSessions == 1 {
            awardFreezeIfUnderCap(id: "starter", source: "first_session")
        }

        // Push fresh widget data so the home-screen streak widget doesn't lag the save.
        refreshWidgetData()

        return session
    }

    /// Grant a freeze if the user is under the 3-freeze cap. Freezes no longer expire.
    /// Fire-and-forget with severe logging on failure.
    private func awardFreezeIfUnderCap(id: String, source: String) {
        let current = streakManager.currentStreakData.freezesAvailableCount ?? 0
        guard current < Self.freezeCap else { return }
        Task {
            do {
                _ = try await streakManager.addStreakFreeze(id: id, dateExpires: nil)
                logManager.trackEvent(eventName: "Freeze_Awarded", parameters: ["source": source, "id": id], type: .analytic)
            } catch {
                logRewardFailure(source: "freeze_\(source)", error: error)
            }
        }
    }

    func awardCheckInXP() {
        let reward = XPRewardCalculator.checkInReward()
        let oldXP = xpManager.currentExperiencePointsData.pointsAllTime ?? 0
        Task {
            do {
                try await xpManager.addExperiencePoints(points: reward.totalPoints, metadata: [
                    "source": .string("check_in")
                ])
            } catch {
                logRewardFailure(source: "check_in", error: error)
            }
            fireXPToast(points: reward.totalPoints, oldXP: oldXP)
        }
    }

    func awardStreakMilestoneXP() {
        let reward = XPRewardCalculator.streakMilestoneReward()
        let oldXP = xpManager.currentExperiencePointsData.pointsAllTime ?? 0
        Task {
            do {
                try await xpManager.addExperiencePoints(points: reward.totalPoints, metadata: [
                    "source": .string("streak_milestone")
                ])
            } catch {
                logRewardFailure(source: "streak_milestone", error: error)
            }
            fireXPToast(points: reward.totalPoints, oldXP: oldXP)
        }
    }

    // MARK: - Private

    private func calculateSessionXP(params: SessionEntryParams, streakDays: Int) -> SessionXPResult {
        let recent = recentFocusAreas(withinDays: 30)
        let reward = XPRewardCalculator.calculate(params: params, recentFocusAreas: recent)
        let multiplier = XPMultiplierCalculator.calculate(streakDays: streakDays, sessionsLastWeek: sessionsLastWeek())
        // Apply multiplier, then clamp by daily cap (computed from today's already-earned session XP).
        let boosted = XPMultiplierCalculator.apply(multiplier, toBasePoints: reward.totalPoints)
        let earnedToday = sessionXPEarnedToday()
        let remaining = max(0, XPRewardCalculator.dailySessionXPCap - earnedToday)
        let points = min(boosted, remaining)

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
        let newStreakDays = streakManager.currentStreakData.currentStreak ?? 0
        if let newTier = XPMultiplierCalculator.streakTierUp(oldDays: oldStreakDays, newDays: newStreakDays) {
            appState.pendingStreakTierUp = newTier
            // Streak-tier up is a textbook positive moment — ask for a review.
            maybePromptReview(trigger: .streakMilestone)
        }

        fireXPToast(
            points: finalPoints,
            oldXP: oldXP,
            breakdownText: xpReward.breakdownText,
            multiplierText: multiplier.displayText,
            isFireRound: multiplier.isFireRound
        )

        let stats = sessionManager.getSessionStats()
        achievementManager.checkAndAward(
            event: .sessionLogged(totalCount: stats.totalSessions, streakCount: streakManager.currentStreakData.currentStreak ?? 0),
            sessionStats: stats,
            streakCount: streakManager.currentStreakData.currentStreak ?? 0
        )

        // Session-count milestones — user has committed enough to have an opinion.
        if Self.ratingSessionMilestones.contains(stats.totalSessions) {
            maybePromptReview(trigger: .sessionMilestone)
        }

        handleWeeklyChallengeEvaluation()
    }

    private static let ratingSessionMilestones: Set<Int> = [10, 25, 50, 100]

    // MARK: - Daily XP Cap Tracking
    // Lightweight UserDefaults-backed counter so we can clamp without hitting Firebase per session.

    private static let dailyXPEarnedKey = "xp.session.earnedToday.points"
    private static let dailyXPDateKey = "xp.session.earnedToday.dateKey"

    private func sessionXPEarnedToday() -> Int {
        let today = Self.todayKey()
        let storedDay = UserDefaults.standard.string(forKey: Self.dailyXPDateKey)
        guard storedDay == today else { return 0 }
        return UserDefaults.standard.integer(forKey: Self.dailyXPEarnedKey)
    }

    private func recordSessionXPEarnedToday(_ points: Int) {
        guard points > 0 else { return }
        let today = Self.todayKey()
        let storedDay = UserDefaults.standard.string(forKey: Self.dailyXPDateKey)
        let current = storedDay == today ? UserDefaults.standard.integer(forKey: Self.dailyXPEarnedKey) : 0
        UserDefaults.standard.set(current + points, forKey: Self.dailyXPEarnedKey)
        UserDefaults.standard.set(today, forKey: Self.dailyXPDateKey)
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    /// Defer slightly so any XP/tier-up toast or modal animates first; the rating prompt
    /// lands after the user has seen their reward, not on top of it.
    private func maybePromptReview(trigger: RatingPromptTrigger) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            AppStoreRatingsHelper.requestReview(trigger: trigger)
        }
    }

    private func handleWeeklyChallengeEvaluation() {
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else { return }
        let weekSessions = sessionManager.sessions.filter { $0.date >= weekStart && $0.date < weekEnd }

        guard let latestSession = weekSessions.sorted(by: { $0.date > $1.date }).first else { return }

        let completedBefore = challengeManager.completedCount
        let newlyCompleted = challengeManager.evaluate(
            session: latestSession,
            allSessionsThisWeek: weekSessions,
            gyms: classScheduleManager.gyms,
            techniques: techniqueManager.techniques,
            weekStart: weekStart
        )
        let completedAfter = challengeManager.completedCount

        for challenge in newlyCompleted {
            let reward = XPRewardCalculator.weeklyChallengeReward()
            let challengeType = challenge.challengeType.rawValue
            Task {
                do {
                    try await xpManager.addExperiencePoints(points: reward.totalPoints, metadata: [
                        "source": .string("weekly_challenge"),
                        "challenge_type": .string(challengeType)
                    ])
                } catch {
                    logRewardFailure(source: "weekly_challenge", error: error, extra: ["challenge_type": challengeType])
                }
            }
            appState.pendingChallengeCompletion = challenge.title
        }

        if completedBefore < 2, completedAfter >= 2 {
            let weekId = Int(weekStart.timeIntervalSince1970)
            awardFreezeIfUnderCap(id: "weekly_challenge_\(weekId)", source: "weekly_challenge")
        }

        if completedBefore < 3, completedAfter >= 3 {
            let sweepReward = XPRewardCalculator.weeklyChallengeSweepBonus()
            Task {
                do {
                    try await xpManager.addExperiencePoints(points: sweepReward.totalPoints, metadata: [
                        "source": .string("weekly_challenge_sweep")
                    ])
                } catch {
                    logRewardFailure(source: "weekly_challenge_sweep", error: error)
                }
            }
            // Earning a fire round is now the reward for sweeping — no more random rolls.
            XPMultiplierCalculator.activateFireRound()
            appState.pendingFireRoundActivation = true
            // A full sweep is the best-feeling moment in the weekly loop.
            maybePromptReview(trigger: .weeklyChallengeSweep)
        }
    }

    /// After a session is saved, find the first technique (from focusAreas + techniquesWorked)
    /// that has accumulated enough practice sessions to warrant a stage promotion and surface
    /// the prompt via AppState. Only the first eligible technique is surfaced per session save
    /// to avoid overwhelming the user.
    private func checkTechniquePromotions(techniquesWorked: [String]) {
        let allSessions = sessionManager.sessions
        for name in techniquesWorked {
            guard let technique = techniqueManager.techniques.first(where: {
                $0.name.lowercased() == name.lowercased()
            }) else { continue }

            // Count sessions that mention this technique in focusAreas or techniquesWorked
            let practiceCount = allSessions.filter { session in
                let focusMatch = session.focusAreas.contains(where: { $0.lowercased() == name.lowercased() })
                let techniqueMatch = session.techniquesWorked.contains(where: { $0.lowercased() == name.lowercased() })
                return focusMatch || techniqueMatch
            }.count

            guard let suggested = ProgressionStage.suggestedPromotion(
                currentStage: technique.stage,
                practiceCount: practiceCount
            ) else { continue }

            appState.pendingTechniquePromotion = TechniquePromotionData(
                techniqueId: technique.techniqueId,
                techniqueName: technique.name,
                currentStage: technique.stage.rawValue.capitalized,
                suggestedStage: suggested.rawValue.capitalized,
                practiceCount: practiceCount
            )
            break
        }
    }

    /// Fire-and-forget reward writes can't surface an alert to the user, but they must
    /// not silently disappear. Log as `.severe` so Crashlytics captures the class.
    private func logRewardFailure(source: String, error: Error, extra: [String: String] = [:]) {
        var params: [String: Any] = ["source": source, "error": String(describing: error)]
        for (key, value) in extra {
            params[key] = value
        }
        logManager.trackEvent(
            eventName: "SessionLoggingService_RewardWriteFailed",
            parameters: params,
            type: .severe
        )
    }

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
