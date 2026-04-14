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

    // MARK: - Public Entry Points

    func logSession(params: SessionEntryParams) async throws -> BJJSessionModel {
        let session = try sessionManager.createSession(
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

        let oldStreakDays = streakManager.currentStreakData.currentStreak ?? 0
        let result = calculateSessionXP(params: params, streakDays: oldStreakDays)
        let oldXP = xpManager.currentExperiencePointsData.pointsAllTime ?? 0

        async let streakResult = streakManager.addStreakEvent(metadata: [:])
        async let xpResult = xpManager.addExperiencePoints(points: result.points, metadata: result.metadata)
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
        let newStreakDays = streakManager.currentStreakData.currentStreak ?? 0
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

        let stats = sessionManager.getSessionStats()
        achievementManager.checkAndAward(
            event: .sessionLogged(totalCount: stats.totalSessions, streakCount: streakManager.currentStreakData.currentStreak ?? 0),
            sessionStats: stats,
            streakCount: streakManager.currentStreakData.currentStreak ?? 0
        )

        handleWeeklyChallengeEvaluation()
    }

    // swiftlint:disable:next function_body_length
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
            let freezeId = "weekly_challenge_\(weekId)"
            let nextMonday = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)
            Task {
                do {
                    try await streakManager.addStreakFreeze(id: freezeId, dateExpires: nextMonday)
                } catch {
                    logRewardFailure(source: "weekly_challenge_freeze_reward", error: error)
                }
            }
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
