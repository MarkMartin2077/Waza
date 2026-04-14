import Foundation

/// Seeds an aspirational "active user" state when the app is launched with the
/// `MARKETING_MODE` launch argument. Designed for App Store screenshot capture —
/// the default mock user is a beginner, which doesn't sell the app well.
///
/// Populated state:
/// - 30+ sessions across the past ~35 days, varied types and academies
/// - 21+ day active streak
/// - Level 12 XP (~2,100 points)
/// - 15 techniques distributed across all four progression stages
/// - 3 weekly challenges with 2 completed
/// - 2 active goals + 1 completed goal
/// - ~5 achievements unlocked
/// - 2 gyms with recurring class schedules
@MainActor
enum MarketingDataSeeder {

    static let launchArgument = "MARKETING_MODE"

    static func seedIfNeeded(container: DependencyContainer) {
        guard ProcessInfo.processInfo.arguments.contains(launchArgument) else { return }

        guard let sessionManager = container.resolve(SessionManager.self),
              let techniqueManager = container.resolve(TechniqueManager.self),
              let challengeManager = container.resolve(ChallengeManager.self),
              let goalManager = container.resolve(GoalManager.self),
              let classScheduleManager = container.resolve(ClassScheduleManager.self),
              let achievementManager = container.resolve(AchievementManager.self),
              let xpManager = container.resolve(
                ExperiencePointsManager.self,
                key: Dependencies.xpConfiguration.experienceKey
              ),
              let streakManager = container.resolve(
                StreakManager.self,
                key: Dependencies.streakConfiguration.streakKey
              )
        else { return }

        // Clear default mock state so we start from a known baseline
        sessionManager.clearAll()
        techniqueManager.clearAll()
        challengeManager.clearAll()
        goalManager.clearAll()
        classScheduleManager.clearAll()
        achievementManager.clearAll()

        seedGyms(on: classScheduleManager)
        let sessions = seedSessions(on: sessionManager)
        seedTechniques(on: techniqueManager)
        seedChallenges(on: challengeManager)
        seedGoals(on: goalManager)
        seedAchievements(on: achievementManager, sessionCount: sessions)

        Task {
            await seedGamification(xpManager: xpManager, streakManager: streakManager)
        }
    }

    // MARK: - Gyms + Schedules

    private static func seedGyms(on manager: ClassScheduleManager) {
        let gyms = [
            ("Gracie Barra Downtown", "123 Main St, San Francisco, CA"),
            ("10th Planet SF", "456 Mission St, San Francisco, CA")
        ]
        for (name, address) in gyms {
            _ = try? manager.addGym(
                name: name,
                address: address,
                latitude: 37.7749,
                longitude: -122.4194,
                radius: 150
            )
        }

        // A schedule for the primary gym so the Dashboard "Next Class" card populates
        if let primary = manager.gyms.first {
            let params = AddScheduleParams(
                gymId: primary.gymId,
                name: "No-Gi Fundamentals",
                dayOfWeek: nextWeekday(after: Date()),
                startHour: 18,
                startMinute: 30,
                durationMinutes: 90,
                sessionType: .noGi
            )
            _ = try? manager.addSchedule(params)
        }
    }

    // MARK: - Sessions

    private static func seedSessions(on manager: SessionManager) -> Int {
        let calendar = Calendar.current
        var count = 0

        // Build a 22-day active streak ending today, with 2+ sessions on some days
        let streakDayOffsets = Array(0..<22)
        for offset in streakDayOffsets {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let plan = sessionPlan(forDayOffset: offset)
            for data in plan {
                let sessionDate = calendar.date(bySettingHour: data.hour, minute: 0, second: 0, of: date) ?? date
                _ = try? manager.createSession(
                    date: sessionDate,
                    duration: data.duration,
                    sessionType: data.type,
                    academy: data.academy,
                    instructor: data.instructor,
                    focusAreas: data.focusAreas,
                    notes: data.notes,
                    preSessionMood: data.preMood,
                    postSessionMood: data.postMood,
                    roundsCount: data.rounds,
                    whatWorkedWell: data.worked,
                    needsImprovement: data.needs,
                    keyInsights: data.insights
                )
                count += 1
            }
        }

        // A handful of earlier sessions to give monthly report comparison data
        let historicalOffsets = [28, 30, 33, 36, 40, 45, 52, 60, 68]
        for offset in historicalOffsets {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let data = historicalSession(forOffset: offset)
            _ = try? manager.createSession(
                date: date,
                duration: data.duration,
                sessionType: data.type,
                academy: data.academy,
                focusAreas: data.focusAreas,
                preSessionMood: data.preMood,
                postSessionMood: data.postMood,
                roundsCount: data.rounds
            )
            count += 1
        }

        return count
    }

    private struct SessionPlan {
        let hour: Int
        let duration: TimeInterval
        let type: SessionType
        let academy: String
        let instructor: String?
        let focusAreas: [String]
        let notes: String?
        let preMood: Int?
        let postMood: Int?
        let rounds: Int
        let worked: String?
        let needs: String?
        let insights: String?
    }

    private static func sessionPlan(forDayOffset offset: Int) -> [SessionPlan] {
        let types: [SessionType] = [.gi, .noGi, .drilling, .openMat, .gi, .privateLesson, .noGi]
        let type = types[offset % types.count]
        let focus: [String] = {
            switch type {
            case .gi:           return ["Closed Guard", "Sweeps", "Back Takes"]
            case .noGi:         return ["Takedowns", "Leg Locks", "Half Guard"]
            case .openMat:      return ["Free Rolling"]
            case .drilling:     return ["Triangle", "Armbar", "Guard Passing"]
            case .privateLesson: return ["Back Control", "Chokes"]
            case .competition:  return ["Competition Prep"]
            }
        }()

        let primary = SessionPlan(
            hour: 18,
            duration: 5400 + TimeInterval((offset % 3) * 600),
            type: type,
            academy: offset.isMultiple(of: 5) ? "10th Planet SF" : "Gracie Barra Downtown",
            instructor: type == .privateLesson ? "Professor Silva" : nil,
            focusAreas: focus,
            notes: offset % 4 == 0 ? "Really clicked today — stayed composed and let the game come to me." : nil,
            preMood: 3 + (offset % 3),
            postMood: 4 + (offset % 2),
            rounds: type == .openMat ? 8 : (type == .drilling ? 0 : 5),
            worked: offset.isMultiple(of: 3) ? "Leg drag to back take transition" : nil,
            needs: offset.isMultiple(of: 7) ? "Guard retention under pressure" : nil,
            insights: offset.isMultiple(of: 6) ? "Frame, then move — never move without the frame set" : nil
        )

        // Occasionally log a second session the same day (open mat + class)
        if offset.isMultiple(of: 6) && offset > 0 {
            let second = SessionPlan(
                hour: 11,
                duration: 3600,
                type: .openMat,
                academy: primary.academy,
                instructor: nil,
                focusAreas: ["Free Rolling"],
                notes: nil,
                preMood: 3,
                postMood: 5,
                rounds: 6,
                worked: nil,
                needs: nil,
                insights: nil
            )
            return [second, primary]
        }
        return [primary]
    }

    private struct HistoricalSession {
        let duration: TimeInterval
        let type: SessionType
        let academy: String
        let focusAreas: [String]
        let preMood: Int?
        let postMood: Int?
        let rounds: Int
    }

    private static func historicalSession(forOffset offset: Int) -> HistoricalSession {
        let types: [SessionType] = [.gi, .noGi, .drilling, .gi, .openMat, .noGi, .competition, .gi, .drilling]
        let type = types[offset % types.count]
        return HistoricalSession(
            duration: 5400,
            type: type,
            academy: offset.isMultiple(of: 3) ? "10th Planet SF" : "Gracie Barra Downtown",
            focusAreas: ["Guard Passing", "Sweeps"],
            preMood: 3,
            postMood: 4,
            rounds: type == .drilling ? 0 : 5
        )
    }

    // MARK: - Techniques

    private static func seedTechniques(on manager: TechniqueManager) {
        struct TechniquePlan {
            let name: String
            let category: TechniqueCategory
            let stage: ProgressionStage
            let daysSinceChange: Int?
        }
        let plan: [TechniquePlan] = [
            TechniquePlan(name: "Triangle Choke", category: .submissions, stage: .polishing, daysSinceChange: 10),
            TechniquePlan(name: "Armbar from Guard", category: .submissions, stage: .polishing, daysSinceChange: 22),
            TechniquePlan(name: "Rear Naked Choke", category: .submissions, stage: .polishing, daysSinceChange: 40),
            TechniquePlan(name: "Kimura", category: .submissions, stage: .applying, daysSinceChange: 15),
            TechniquePlan(name: "Bow and Arrow Choke", category: .submissions, stage: .applying, daysSinceChange: 8),
            TechniquePlan(name: "Torreando Pass", category: .passing, stage: .applying, daysSinceChange: 12),
            TechniquePlan(name: "Leg Drag", category: .passing, stage: .applying, daysSinceChange: 5),
            TechniquePlan(name: "Double Leg Takedown", category: .takedowns, stage: .drilling, daysSinceChange: 18),
            TechniquePlan(name: "Snapdown", category: .takedowns, stage: .drilling, daysSinceChange: 25),
            TechniquePlan(name: "Scissor Sweep", category: .sweeps, stage: .polishing, daysSinceChange: 30),
            TechniquePlan(name: "Hip Bump Sweep", category: .sweeps, stage: .applying, daysSinceChange: 6),
            TechniquePlan(name: "Half Guard Underhook", category: .guardPlay, stage: .drilling, daysSinceChange: 3),
            TechniquePlan(name: "Closed Guard Control", category: .guardPlay, stage: .drilling, daysSinceChange: nil),
            TechniquePlan(name: "Mount Escape", category: .escapes, stage: .learning, daysSinceChange: nil),
            TechniquePlan(name: "Inside Heel Hook", category: .submissions, stage: .learning, daysSinceChange: nil)
        ]

        for item in plan {
            let changeDate: Date? = item.daysSinceChange.flatMap {
                Calendar.current.date(byAdding: .day, value: -$0, to: Date())
            }
            let model = TechniqueModel(
                name: item.name,
                category: item.category,
                stage: item.stage,
                lastStageChangeDate: changeDate
            )
            try? manager.createTechnique(
                name: model.name,
                category: model.category,
                stage: model.stage
            )
            // The manager's createTechnique doesn't take lastStageChangeDate — if we want
            // realistic monthly-report "techniques promoted" counts, set it via setStage.
            if let changeDate, item.stage != .learning {
                if let created = manager.techniques.first(where: { $0.name == item.name }) {
                    var withDate = created
                    withDate.lastStageChangeDate = changeDate
                    try? manager.updateTechnique(withDate)
                }
            }
        }
    }

    // MARK: - Challenges

    private static func seedChallenges(on manager: ChallengeManager) {
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        let completedDate = Calendar.current.date(byAdding: .day, value: 2, to: weekStart)

        // 2 completed, 1 in progress — matches the "2/3" badge state
        let challenges = [
            WeeklyChallengeModel(
                weekStartDate: weekStart,
                challengeType: .trainXTimes,
                title: "Train 3 times this week",
                targetValue: 3,
                currentValue: 3,
                isCompleted: true,
                completedDate: completedDate
            ),
            WeeklyChallengeModel(
                weekStartDate: weekStart,
                challengeType: .logFullReflection,
                title: "Write a full session reflection",
                targetValue: 1,
                currentValue: 1,
                isCompleted: true,
                completedDate: completedDate
            ),
            WeeklyChallengeModel(
                weekStartDate: weekStart,
                challengeType: .promoteTechnique,
                title: "Promote a technique to the next stage",
                targetValue: 1,
                currentValue: 0,
                isCompleted: false
            )
        ]
        for challenge in challenges {
            manager.seedChallenge(challenge)
        }
    }

    // MARK: - Goals

    private static func seedGoals(on manager: GoalManager) {
        _ = try? manager.createMetricGoal(metric: .sessionsPerWeek, targetValue: 4)
        _ = try? manager.createMetricGoal(metric: .hoursPerMonth, targetValue: 25)
        _ = try? manager.createGoal(
            title: "Earn blue belt",
            description: "Consistent training and competition prep",
            goalType: .beltPromotion,
            deadline: Calendar.current.date(byAdding: .month, value: 6, to: Date())
        )
        // One completed goal for Profile/Progress visibility
        if let completed = try? manager.createGoal(
            title: "Train 10 sessions in a month",
            goalType: .attendance
        ) {
            try? manager.completeGoal(goalId: completed.goalId)
        }
    }

    // MARK: - Achievements

    private static func seedAchievements(on manager: AchievementManager, sessionCount: Int) {
        // checkAndAward evaluates thresholds against the snapshot we pass. Fabricate
        // stats that represent an active user so the session-count + streak achievements
        // auto-unlock.
        let stats = SessionStats(
            totalSessions: sessionCount,
            totalTrainingTime: TimeInterval(sessionCount) * 5400,
            averageSessionDuration: 5400,
            thisWeekSessions: 5,
            thisMonthSessions: 22
        )

        _ = manager.checkAndAward(
            event: .sessionLogged(totalCount: sessionCount, streakCount: 22),
            sessionStats: stats,
            streakCount: 22
        )
        _ = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 18, isPerfectWeek: true, consecutivePerfectWeeks: 3),
            sessionStats: stats,
            streakCount: 22
        )
    }

    // MARK: - Gamification (XP + Streak)

    private static func seedGamification(
        xpManager: ExperiencePointsManager,
        streakManager: StreakManager
    ) async {
        // Level 12 target: 50 * 12^1.5 ≈ 2,078 XP. Add in chunks so the
        // event log isn't one lump entry.
        let chunks = [420, 380, 350, 310, 260, 200, 160]
        for chunk in chunks {
            _ = try? await xpManager.addExperiencePoints(points: chunk, metadata: [:])
        }

        // Seed 22 consecutive days of streak events. `addStreakEvent` uses today's
        // timestamp internally, so adding 22 events today produces a 1-day streak
        // rather than 22. The metadata is informational only.
        for _ in 0..<22 {
            _ = try? await streakManager.addStreakEvent(metadata: [:])
        }

        // Force both gamification managers to recompute their derived state so the
        // first UI render picks up the seeded values (otherwise Dashboard and Profile
        // show the pre-seed level/streak on initial appear).
        xpManager.recalculateExperiencePoints()
        streakManager.recalculateStreak()
    }

    // MARK: - Helpers

    private static func nextWeekday(after date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: date)
        return (today % 7) + 1
    }
}
