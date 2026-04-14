import Testing
import Foundation
@testable import Waza

// MARK: - Helpers

@MainActor
private func makeManager() -> ChallengeManager {
    ChallengeManager(localService: SwiftDataChallengePersistence(inMemory: true))
}

@MainActor
private func seedChallenge(
    on manager: ChallengeManager,
    type: ChallengeType,
    target: Int,
    metadata: String? = nil,
    weekStart: Date = WeeklyChallengeModel.currentWeekStart()
) -> WeeklyChallengeModel {
    let challenge = WeeklyChallengeModel(
        weekStartDate: weekStart,
        challengeType: type,
        title: "Test \(type.rawValue)",
        targetValue: target,
        metadata: metadata
    )
    let persistence = SwiftDataChallengePersistence(inMemory: true)
    _ = persistence
    // Insert via the manager's service by bypassing and using the public seed path.
    // Since we cannot reach the private localService directly, create via an accessor path.
    // Simpler: mutate the manager's challenges array by creating a brand-new manager preloaded.
    // For these tests, use the direct service injection pattern instead:
    return challenge
}

/// Creates a manager seeded with one challenge of the given type for the current week.
@MainActor
private func managerWithChallenge(
    type: ChallengeType,
    target: Int,
    metadata: String? = nil
) -> (manager: ChallengeManager, challenge: WeeklyChallengeModel) {
    let service = SwiftDataChallengePersistence(inMemory: true)
    let challenge = WeeklyChallengeModel(
        weekStartDate: WeeklyChallengeModel.currentWeekStart(),
        challengeType: type,
        title: "Test \(type.rawValue)",
        targetValue: target,
        metadata: metadata
    )
    try? service.create(challenge)
    let manager = ChallengeManager(localService: service)
    return (manager, challenge)
}

private func weekSession(
    dayOffset: Int = 0,
    type: SessionType = .gi,
    academy: String? = "Home Gym",
    duration: TimeInterval = 3600,
    focusAreas: [String] = [],
    preMood: Int? = nil,
    postMood: Int? = nil,
    notes: String? = nil,
    worked: String? = nil,
    needs: String? = nil,
    insights: String? = nil
) -> BJJSessionModel {
    let weekStart = WeeklyChallengeModel.currentWeekStart()
    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
    return BJJSessionModel(
        date: date,
        duration: duration,
        sessionType: type,
        academy: academy,
        focusAreas: focusAreas,
        notes: notes,
        preSessionMood: preMood,
        postSessionMood: postMood,
        whatWorkedWell: worked,
        needsImprovement: needs,
        keyInsights: insights
    )
}

// MARK: - trainXTimes Evaluation

@Suite("ChallengeManager - trainXTimes") @MainActor
struct ChallengeManagerTrainXTimesTests {

    @Test("Completes when session count reaches target")
    func completesAtTarget() {
        // GIVEN — challenge targeting 3 sessions
        let (manager, _) = managerWithChallenge(type: .trainXTimes, target: 3)
        let sessions = [weekSession(dayOffset: 0), weekSession(dayOffset: 1), weekSession(dayOffset: 2)]

        // WHEN
        let trigger = sessions[2]
        let completed = manager.evaluate(session: trigger, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
        #expect(manager.currentChallenges.first?.isCompleted == true)
        #expect(manager.currentChallenges.first?.currentValue == 3)
    }

    @Test("Stays incomplete below target")
    func incompleteBelowTarget() {
        // GIVEN — challenge targeting 5
        let (manager, _) = managerWithChallenge(type: .trainXTimes, target: 5)
        let sessions = [weekSession(dayOffset: 0), weekSession(dayOffset: 1)]

        // WHEN
        let completed = manager.evaluate(session: sessions.last!, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
        #expect(manager.currentChallenges.first?.isCompleted == false)
        #expect(manager.currentChallenges.first?.currentValue == 2)
    }

    @Test("Already-completed challenge is not re-evaluated")
    func alreadyCompletedStaysCompleted() {
        // GIVEN — challenge already marked complete
        let service = SwiftDataChallengePersistence(inMemory: true)
        var challenge = WeeklyChallengeModel(
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            challengeType: .trainXTimes,
            title: "done",
            targetValue: 3
        )
        challenge.currentValue = 3
        challenge.isCompleted = true
        challenge.completedDate = Date()
        try? service.create(challenge)
        let manager = ChallengeManager(localService: service)

        // WHEN — even with 0 sessions
        let dummy = weekSession(dayOffset: 0)
        let newlyCompleted = manager.evaluate(session: dummy, allSessionsThisWeek: [], gyms: [])

        // THEN
        #expect(newlyCompleted.isEmpty)
        #expect(manager.currentChallenges.first?.isCompleted == true)
    }
}

// MARK: - logSessionType Evaluation

@Suite("ChallengeManager - logSessionType") @MainActor
struct ChallengeManagerSessionTypeTests {

    @Test("Counts only sessions of the target type")
    func matchesOnlyTargetType() {
        // GIVEN — challenge for openMat
        let (manager, _) = managerWithChallenge(
            type: .logSessionType,
            target: 1,
            metadata: SessionType.openMat.rawValue
        )
        let sessions = [
            weekSession(dayOffset: 0, type: .gi),
            weekSession(dayOffset: 1, type: .noGi),
            weekSession(dayOffset: 2, type: .openMat)
        ]

        // WHEN
        let completed = manager.evaluate(session: sessions[2], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
        #expect(manager.currentChallenges.first?.currentValue == 1)
    }

    @Test("No match leaves challenge incomplete")
    func noMatchingType() {
        // GIVEN — challenge for drilling
        let (manager, _) = managerWithChallenge(
            type: .logSessionType,
            target: 1,
            metadata: SessionType.drilling.rawValue
        )
        let sessions = [weekSession(dayOffset: 0, type: .gi), weekSession(dayOffset: 1, type: .noGi)]

        // WHEN
        let completed = manager.evaluate(session: sessions.last!, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
        #expect(manager.currentChallenges.first?.currentValue == 0)
    }
}

// MARK: - miniStreak Evaluation

@Suite("ChallengeManager - miniStreak") @MainActor
struct ChallengeManagerMiniStreakTests {

    @Test("Two consecutive days completes the challenge")
    func consecutiveDaysCompletes() {
        // GIVEN
        let (manager, _) = managerWithChallenge(type: .miniStreak, target: 2)
        let sessions = [weekSession(dayOffset: 0), weekSession(dayOffset: 1)]

        // WHEN
        let completed = manager.evaluate(session: sessions.last!, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
    }

    @Test("Gap between days keeps challenge incomplete")
    func nonConsecutiveDoesNotCount() {
        // GIVEN — days 0 and 2 (gap on day 1)
        let (manager, _) = managerWithChallenge(type: .miniStreak, target: 2)
        let sessions = [weekSession(dayOffset: 0), weekSession(dayOffset: 2)]

        // WHEN
        let completed = manager.evaluate(session: sessions.last!, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
        #expect(manager.currentChallenges.first?.currentValue == 1)
    }

    @Test("Multiple sessions on the same day count as one day")
    func sameDaySessionsCountOnce() {
        // GIVEN — two sessions on day 0
        let (manager, _) = managerWithChallenge(type: .miniStreak, target: 2)
        let sessions = [weekSession(dayOffset: 0), weekSession(dayOffset: 0)]

        // WHEN
        let completed = manager.evaluate(session: sessions.last!, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
        #expect(manager.currentChallenges.first?.currentValue == 1)
    }
}

// MARK: - newFocusArea Evaluation

@Suite("ChallengeManager - newFocusArea") @MainActor
struct ChallengeManagerNewFocusAreaTests {

    @Test("Training a new focus area completes the challenge")
    func trainingNewFocusAreaCompletes() {
        // GIVEN — recent areas are Guard, Pass
        let (manager, _) = managerWithChallenge(
            type: .newFocusArea,
            target: 1,
            metadata: "Guard,Pass"
        )
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["Takedowns"])]

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
    }

    @Test("Training only recent focus areas leaves challenge incomplete")
    func trainingOnlyRecentAreasFails() {
        // GIVEN
        let (manager, _) = managerWithChallenge(
            type: .newFocusArea,
            target: 1,
            metadata: "Guard,Pass"
        )
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["Guard"])]

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
    }

    @Test("Empty metadata treats any focus area as new")
    func emptyMetadataAnyAreaCounts() {
        // GIVEN — no recent areas tracked
        let (manager, _) = managerWithChallenge(type: .newFocusArea, target: 1, metadata: "")
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["Guard"])]

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
    }
}

// MARK: - trainAtDifferentGym Evaluation

@Suite("ChallengeManager - trainAtDifferentGym") @MainActor
struct ChallengeManagerDifferentGymTests {

    @Test("Training at a non-primary gym completes the challenge")
    func differentGymCompletes() {
        // GIVEN — primary gym is Home Gym
        let (manager, _) = managerWithChallenge(
            type: .trainAtDifferentGym,
            target: 1,
            metadata: "Home Gym"
        )
        let sessions = [weekSession(dayOffset: 0, academy: "Visitor Gym")]

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
    }

    @Test("Same-gym session keeps challenge incomplete (case insensitive)")
    func samePrimaryGymFails() {
        // GIVEN
        let (manager, _) = managerWithChallenge(
            type: .trainAtDifferentGym,
            target: 1,
            metadata: "Home Gym"
        )
        let sessions = [weekSession(dayOffset: 0, academy: "home gym")]

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
    }

    @Test("Nil academy does not trigger completion")
    func nilAcademyDoesNotCount() {
        // GIVEN
        let (manager, _) = managerWithChallenge(
            type: .trainAtDifferentGym,
            target: 1,
            metadata: "Home Gym"
        )
        let sessions = [weekSession(dayOffset: 0, academy: nil)]

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
    }
}

// MARK: - Mood & Reflection Evaluation

@Suite("ChallengeManager - Mood & Reflection") @MainActor
struct ChallengeManagerQualityTests {

    @Test("Session with both pre/post mood completes logMoodBothWays")
    func bothMoodsComplete() {
        let (manager, _) = managerWithChallenge(type: .logMoodBothWays, target: 1)
        let sessions = [weekSession(dayOffset: 0, preMood: 3, postMood: 4)]

        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        #expect(completed.count == 1)
    }

    @Test("Only one mood recorded leaves challenge incomplete")
    func onlyOneMoodFails() {
        let (manager, _) = managerWithChallenge(type: .logMoodBothWays, target: 1)
        let sessions = [weekSession(dayOffset: 0, preMood: 3, postMood: nil)]

        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        #expect(completed.isEmpty)
    }

    @Test("All four reflection fields populated completes logFullReflection")
    func fullReflectionCompletes() {
        let (manager, _) = managerWithChallenge(type: .logFullReflection, target: 1)
        let sessions = [
            weekSession(
                dayOffset: 0,
                notes: "drilled",
                worked: "leg drag",
                needs: "defense",
                insights: "hip angle"
            )
        ]

        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        #expect(completed.count == 1)
    }

    @Test("Missing any reflection field leaves challenge incomplete")
    func missingReflectionFieldFails() {
        let (manager, _) = managerWithChallenge(type: .logFullReflection, target: 1)
        let sessions = [
            weekSession(
                dayOffset: 0,
                notes: "drilled",
                worked: "leg drag",
                needs: nil,
                insights: "hip angle"
            )
        ]

        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        #expect(completed.isEmpty)
    }

    @Test("Whitespace-only reflection fields count as empty")
    func whitespaceReflectionFails() {
        let (manager, _) = managerWithChallenge(type: .logFullReflection, target: 1)
        let sessions = [
            weekSession(
                dayOffset: 0,
                notes: "real notes",
                worked: "   ",
                needs: "real",
                insights: "real"
            )
        ]

        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        #expect(completed.isEmpty)
    }
}

// MARK: - trainDuration Evaluation

@Suite("ChallengeManager - trainDuration") @MainActor
struct ChallengeManagerDurationTests {

    @Test("A 90+ minute session completes the challenge (threshold in metadata)")
    func longSessionCompletes() {
        // GIVEN — threshold 90 minutes stored in metadata, target is binary 1
        let (manager, _) = managerWithChallenge(type: .trainDuration, target: 1, metadata: "90")
        let sessions = [weekSession(dayOffset: 0, duration: 5400)] // 90 minutes exactly

        // WHEN
        let completed = manager.evaluate(session: sessions[0], allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.count == 1)
    }

    @Test("Short sessions leave the challenge incomplete")
    func shortSessionsFail() {
        // GIVEN — only 60-minute sessions, threshold 90
        let (manager, _) = managerWithChallenge(type: .trainDuration, target: 1, metadata: "90")
        let sessions = [weekSession(dayOffset: 0, duration: 3600), weekSession(dayOffset: 1, duration: 3600)]

        // WHEN
        let completed = manager.evaluate(session: sessions.last!, allSessionsThisWeek: sessions, gyms: [])

        // THEN
        #expect(completed.isEmpty)
    }
}

// MARK: - practiceWeakTechnique Evaluation

@Suite("ChallengeManager - practiceWeakTechnique") @MainActor
struct ChallengeManagerPracticeWeakTechniqueTests {

    @Test("Training a Learning-stage technique completes the challenge")
    func trainingLearningStageCompletes() {
        let (manager, _) = managerWithChallenge(type: .practiceWeakTechnique, target: 1)
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .learning),
            TechniqueModel(name: "Armbar", stage: .applying)
        ]
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["Triangle"])]

        let completed = manager.evaluate(
            session: sessions[0],
            allSessionsThisWeek: sessions,
            gyms: [],
            techniques: techniques
        )

        #expect(completed.count == 1)
    }

    @Test("Case-insensitive match between focus area and technique")
    func caseInsensitiveMatch() {
        let (manager, _) = managerWithChallenge(type: .practiceWeakTechnique, target: 1)
        let techniques = [TechniqueModel(name: "Triangle", stage: .learning)]
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["triangle"])]

        let completed = manager.evaluate(
            session: sessions[0],
            allSessionsThisWeek: sessions,
            gyms: [],
            techniques: techniques
        )

        #expect(completed.count == 1)
    }

    @Test("No Learning-stage techniques means challenge can't be completed")
    func noLearningTechniquesCannotComplete() {
        let (manager, _) = managerWithChallenge(type: .practiceWeakTechnique, target: 1)
        let techniques = [TechniqueModel(name: "Triangle", stage: .applying)]
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["Triangle"])]

        let completed = manager.evaluate(
            session: sessions[0],
            allSessionsThisWeek: sessions,
            gyms: [],
            techniques: techniques
        )

        #expect(completed.isEmpty)
    }

    @Test("Training only non-Learning techniques leaves challenge incomplete")
    func trainingOnlyAdvancedTechniquesFails() {
        let (manager, _) = managerWithChallenge(type: .practiceWeakTechnique, target: 1)
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .learning),
            TechniqueModel(name: "Armbar", stage: .polishing)
        ]
        let sessions = [weekSession(dayOffset: 0, focusAreas: ["Armbar"])]

        let completed = manager.evaluate(
            session: sessions[0],
            allSessionsThisWeek: sessions,
            gyms: [],
            techniques: techniques
        )

        #expect(completed.isEmpty)
    }
}

// MARK: - promoteTechnique Evaluation

@Suite("ChallengeManager - promoteTechnique") @MainActor
struct ChallengeManagerPromoteTechniqueTests {

    @Test("A technique promoted within this week completes the challenge")
    func weekPromotionCompletes() {
        let (manager, _) = managerWithChallenge(type: .promoteTechnique, target: 1)
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        let midWeek = Calendar.current.date(byAdding: .day, value: 2, to: weekStart) ?? weekStart
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .drilling, lastStageChangeDate: midWeek)
        ]

        let completed = manager.evaluate(
            session: weekSession(dayOffset: 0),
            allSessionsThisWeek: [],
            gyms: [],
            techniques: techniques,
            weekStart: weekStart
        )

        #expect(completed.count == 1)
    }

    @Test("A technique promoted before this week does not count")
    func pastPromotionDoesNotCount() {
        let (manager, _) = managerWithChallenge(type: .promoteTechnique, target: 1)
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        let lastWeek = Calendar.current.date(byAdding: .day, value: -3, to: weekStart) ?? weekStart
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .drilling, lastStageChangeDate: lastWeek)
        ]

        let completed = manager.evaluate(
            session: weekSession(dayOffset: 0),
            allSessionsThisWeek: [],
            gyms: [],
            techniques: techniques,
            weekStart: weekStart
        )

        #expect(completed.isEmpty)
    }

    @Test("No technique with a stage change date leaves challenge incomplete")
    func noStageChangeDateFails() {
        let (manager, _) = managerWithChallenge(type: .promoteTechnique, target: 1)
        let techniques = [TechniqueModel(name: "Triangle", stage: .drilling)]

        let completed = manager.evaluate(
            session: weekSession(dayOffset: 0),
            allSessionsThisWeek: [],
            gyms: [],
            techniques: techniques
        )

        #expect(completed.isEmpty)
    }
}

// MARK: - Lifecycle

@Suite("ChallengeManager - Lifecycle") @MainActor
struct ChallengeManagerLifecycleTests {

    @Test("generateIfNeeded populates when no challenges exist")
    func generateIfNeededPopulates() {
        let manager = makeManager()
        #expect(manager.currentChallenges.isEmpty)

        let context = ChallengeGenerator.GenerationContext(
            sessions: [],
            gyms: [],
            allFocusAreas: [],
            recentFocusAreas: [],
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            randomSeed: 1
        )
        manager.generateIfNeeded(context: context)

        #expect(!manager.currentChallenges.isEmpty)
    }

    @Test("generateIfNeeded with requireSessionData=true skips when sessions empty")
    func requireSessionDataSkipsWhenEmpty() {
        let manager = makeManager()
        let context = ChallengeGenerator.GenerationContext(
            sessions: [],
            gyms: [],
            allFocusAreas: [],
            recentFocusAreas: [],
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            randomSeed: 1
        )

        manager.generateIfNeeded(context: context, requireSessionData: true)

        #expect(manager.currentChallenges.isEmpty)
    }

    @Test("generateIfNeeded with requireSessionData=true proceeds when sessions present")
    func requireSessionDataProceedsWithSessions() {
        let manager = makeManager()
        let session = weekSession(dayOffset: 0)
        let context = ChallengeGenerator.GenerationContext(
            sessions: [session],
            gyms: [],
            allFocusAreas: [],
            recentFocusAreas: [],
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            randomSeed: 1
        )

        manager.generateIfNeeded(context: context, requireSessionData: true)

        #expect(!manager.currentChallenges.isEmpty)
    }

    @Test("generateIfNeeded with requireSessionData=false generates for new users even with empty sessions")
    func newUserGeneratesWithEmptySessions() {
        let manager = makeManager()
        let context = ChallengeGenerator.GenerationContext(
            sessions: [],
            gyms: [],
            allFocusAreas: [],
            recentFocusAreas: [],
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            randomSeed: 1
        )

        manager.generateIfNeeded(context: context, requireSessionData: false)

        #expect(!manager.currentChallenges.isEmpty)
    }

    @Test("generateIfNeeded is idempotent — second call does not add more")
    func generateIfNeededIdempotent() {
        let manager = makeManager()
        let context = ChallengeGenerator.GenerationContext(
            sessions: [],
            gyms: [],
            allFocusAreas: [],
            recentFocusAreas: [],
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            randomSeed: 1
        )
        manager.generateIfNeeded(context: context)
        let countAfterFirst = manager.currentChallenges.count

        manager.generateIfNeeded(context: context)

        #expect(manager.currentChallenges.count == countAfterFirst)
    }

    @Test("clearAll removes all challenges")
    func clearAllEmpties() {
        let (manager, _) = managerWithChallenge(type: .trainXTimes, target: 3)
        #expect(!manager.challenges.isEmpty)

        manager.clearAll()

        #expect(manager.challenges.isEmpty)
    }

    @Test("completedCount reflects completed challenges only")
    func completedCountAccurate() {
        let service = SwiftDataChallengePersistence(inMemory: true)
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        var done = WeeklyChallengeModel(
            weekStartDate: weekStart,
            challengeType: .trainXTimes,
            title: "a",
            targetValue: 1
        )
        done.currentValue = 1
        done.isCompleted = true
        let pending = WeeklyChallengeModel(
            weekStartDate: weekStart,
            challengeType: .logSessionType,
            title: "b",
            targetValue: 1
        )
        try? service.create(done)
        try? service.create(pending)
        let manager = ChallengeManager(localService: service)

        #expect(manager.completedCount == 1)
    }
}
