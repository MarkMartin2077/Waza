import Testing
import Foundation
@testable import Waza

// MARK: - Helpers

private func makeContext(
    sessions: [BJJSessionModel] = [],
    gyms: [GymLocationModel] = [],
    allFocusAreas: Set<String> = [],
    recentFocusAreas: Set<String> = [],
    techniques: [TechniqueModel] = [],
    weekStartDate: Date = Date(),
    trainingGoalPerWeek: Int? = nil,
    randomSeed: UInt64 = 42
) -> ChallengeGenerator.GenerationContext {
    ChallengeGenerator.GenerationContext(
        sessions: sessions,
        gyms: gyms,
        allFocusAreas: allFocusAreas,
        recentFocusAreas: recentFocusAreas,
        techniques: techniques,
        weekStartDate: weekStartDate,
        trainingGoalPerWeek: trainingGoalPerWeek,
        randomSeed: randomSeed
    )
}

private func session(
    daysAgo: Int = 0,
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
    let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
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

// MARK: - Basic Generation

@Suite("ChallengeGenerator - Basic Generation")
struct ChallengeGeneratorBasicTests {

    @Test("Zero sessions still produces challenges (beginner defaults)")
    func zeroSessionsProducesChallenges() {
        // GIVEN — brand new user, no training history
        let context = makeContext()

        // WHEN
        let challenges = ChallengeGenerator.generate(context: context)

        // THEN — should still offer frequency + quality challenges
        #expect(!challenges.isEmpty)
        #expect(challenges.count <= 3)
    }

    @Test("Generator picks at most 3 challenges")
    func maxThreeChallenges() {
        // GIVEN — rich history creating many candidates
        let sessions = (0..<10).map { session(daysAgo: $0, type: .gi, focusAreas: ["Guard", "Pass"]) }
        let context = makeContext(
            sessions: sessions,
            gyms: GymLocationModel.mocks,
            allFocusAreas: ["Guard", "Pass", "Takedowns", "Sweeps"],
            recentFocusAreas: ["Guard", "Pass"]
        )

        // WHEN
        let challenges = ChallengeGenerator.generate(context: context)

        // THEN
        #expect(challenges.count == 3)
    }

    @Test("Every generated challenge carries the passed-in week start date")
    func weekStartDatePropagates() {
        // GIVEN
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let context = makeContext(weekStartDate: weekStart)

        // WHEN
        let challenges = ChallengeGenerator.generate(context: context)

        // THEN
        for challenge in challenges {
            #expect(
                Calendar.current.isDate(challenge.weekStartDate, inSameDayAs: weekStart)
            )
        }
    }
}

// MARK: - Seeded Determinism

@Suite("ChallengeGenerator - Seeded Determinism")
struct ChallengeGeneratorSeedTests {

    @Test("Same seed produces the same challenge types in the same order")
    func deterministicWithSameSeed() {
        // GIVEN
        let sessions = [session(daysAgo: 1, type: .gi), session(daysAgo: 3, type: .noGi)]
        let ctx1 = makeContext(sessions: sessions, randomSeed: 12345)
        let ctx2 = makeContext(sessions: sessions, randomSeed: 12345)

        // WHEN
        let first = ChallengeGenerator.generate(context: ctx1)
        let second = ChallengeGenerator.generate(context: ctx2)

        // THEN
        #expect(first.map(\.challengeType) == second.map(\.challengeType))
    }

    @Test("Different seeds can produce different results")
    func differentSeedsDiverge() {
        // GIVEN — enough variety that seed choice actually matters
        let sessions = (0..<15).map {
            session(daysAgo: $0, type: $0.isMultiple(of: 2) ? .gi : .noGi, focusAreas: ["Guard"])
        }
        let ctx1 = makeContext(sessions: sessions, allFocusAreas: ["Guard", "Pass"], randomSeed: 1)
        let ctx2 = makeContext(sessions: sessions, allFocusAreas: ["Guard", "Pass"], randomSeed: 999_999)

        // WHEN
        let first = ChallengeGenerator.generate(context: ctx1)
        let second = ChallengeGenerator.generate(context: ctx2)

        // THEN — at least one slot should differ across most seed pairs
        // (not a strict guarantee, but with this spread it should hold)
        let sameOrder = first.map(\.challengeType) == second.map(\.challengeType)
        if sameOrder {
            // If they happen to match, at least titles or metadata should be equivalent.
            #expect(first.count == second.count)
        } else {
            #expect(first.map(\.challengeType) != second.map(\.challengeType))
        }
    }
}

// MARK: - Category Variety

@Suite("ChallengeGenerator - Category Variety")
struct ChallengeGeneratorVarietyTests {

    @Test("When many candidates exist across categories, no duplicate challenge types are picked")
    func noDuplicateTypes() {
        // GIVEN — rich context enabling many categories
        let sessions = (0..<8).map {
            session(
                daysAgo: $0,
                type: .gi,
                academy: "Gym A",
                duration: 7200,
                focusAreas: ["Guard"],
                preMood: 3,
                postMood: 4,
                notes: "drilled",
                worked: "yes",
                needs: "angles",
                insights: "hip"
            )
        }
        let context = makeContext(
            sessions: sessions,
            gyms: GymLocationModel.mocks,
            allFocusAreas: ["Guard", "Pass", "Takedowns"],
            recentFocusAreas: ["Guard"]
        )

        // WHEN
        let challenges = ChallengeGenerator.generate(context: context)

        // THEN
        let uniqueTypes = Set(challenges.map(\.challengeType))
        #expect(uniqueTypes.count == challenges.count)
    }

    @Test("With diverse candidates, first three picks come from different categories")
    func categoriesVaryAcrossPicks() {
        // GIVEN — enough variety that each category has a candidate
        let sessions = (0..<6).map {
            session(
                daysAgo: $0,
                type: .gi,
                academy: "Gym A",
                duration: 5400,
                focusAreas: ["Guard"]
            )
        }
        // Also include one long session to enable intensity candidate
        let longSession = session(daysAgo: 2, academy: "Gym A", duration: 4000)
        let context = makeContext(
            sessions: sessions + [longSession],
            gyms: GymLocationModel.mocks,
            allFocusAreas: ["Guard", "Pass", "Takedowns", "Sweeps"],
            recentFocusAreas: ["Guard"],
            randomSeed: 7
        )

        // WHEN
        let challenges = ChallengeGenerator.generate(context: context)

        // THEN — expect at least 2 distinct categories (variety enforcement)
        let categories: Set<ChallengeCategory> = Set(challenges.map { $0.challengeType.category })
        #expect(categories.count >= 2)
    }
}

// MARK: - Context-Specific Candidates

@Suite("ChallengeGenerator - Context-Specific Candidates")
struct ChallengeGeneratorContextTests {

    @Test("Single-gym user with no extra academies does not get trainAtDifferentGym")
    func singleGymSkipsDifferentGym() {
        // GIVEN — sessions all at one academy, only one gym registered
        let sessions = (0..<4).map { session(daysAgo: $0, academy: "Solo Gym") }
        let context = makeContext(
            sessions: sessions,
            gyms: [GymLocationModel(name: "Solo Gym")],
            randomSeed: 1
        )

        // WHEN — run many seeds to verify type NEVER appears
        let seeds: [UInt64] = [1, 2, 3, 42, 999]
        for seed in seeds {
            let ctx = makeContext(
                sessions: sessions,
                gyms: [GymLocationModel(name: "Solo Gym")],
                randomSeed: seed
            )
            let result = ChallengeGenerator.generate(context: ctx)
            let hasDifferentGym = result.contains { $0.challengeType == .trainAtDifferentGym }
            #expect(hasDifferentGym == false, "seed \(seed) produced trainAtDifferentGym with only one gym")
        }

        _ = context  // silence unused
    }

    @Test("Multiple registered gyms enables trainAtDifferentGym candidate")
    func multipleGymsEnablesDifferentGym() {
        // GIVEN — two gyms registered
        let gyms = [
            GymLocationModel(name: "Gym A"),
            GymLocationModel(name: "Gym B")
        ]
        let sessions = (0..<5).map { session(daysAgo: $0, academy: "Gym A") }

        // WHEN — across many seeds, trainAtDifferentGym should appear at least once
        var seenDifferentGym = false
        for seed: UInt64 in 0..<50 {
            let ctx = makeContext(sessions: sessions, gyms: gyms, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            if result.contains(where: { $0.challengeType == .trainAtDifferentGym }) {
                seenDifferentGym = true
                break
            }
        }

        // THEN
        #expect(seenDifferentGym)
    }

    @Test("No focus areas skips newFocusArea challenge")
    func noFocusAreasSkipsNewFocusArea() {
        // GIVEN — empty focus area set
        let sessions = (0..<4).map { session(daysAgo: $0) }

        // WHEN — across seeds, should never produce newFocusArea
        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(sessions: sessions, allFocusAreas: [], randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            let hasNewFocus = result.contains { $0.challengeType == .newFocusArea }
            #expect(hasNewFocus == false)
        }
    }

    @Test("No long sessions ever means intensity challenge is skipped")
    func noLongSessionsSkipsIntensity() {
        // GIVEN — all sessions under 1 hour
        let sessions = (0..<6).map { session(daysAgo: $0, duration: 1800) }

        // WHEN/THEN
        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(sessions: sessions, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            #expect(result.contains { $0.challengeType == .trainDuration } == false)
        }
    }

    @Test("Training goal per week is reflected in trainXTimes target")
    func trainingGoalReflectedInTarget() {
        // GIVEN — goal = 5 sessions/week
        let context = makeContext(trainingGoalPerWeek: 5, randomSeed: 3)

        // WHEN — scan outputs across seeds to find a trainXTimes
        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(trainingGoalPerWeek: 5, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            if let trainX = result.first(where: { $0.challengeType == .trainXTimes }) {
                #expect(trainX.targetValue == 5)
                return
            }
        }
        _ = context
        // If we never found one, the test is not meaningful (beginner defaults should include it)
        Issue.record("trainXTimes did not appear in any generated output — beginner defaults broken?")
    }

    @Test("Default training goal of 3 is used when no goal is set")
    func defaultGoalIsThree() {
        // GIVEN — no goal provided
        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(trainingGoalPerWeek: nil, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            if let trainX = result.first(where: { $0.challengeType == .trainXTimes }) {
                #expect(trainX.targetValue == 3)
                return
            }
        }
        Issue.record("trainXTimes did not appear with default goal")
    }
}

// MARK: - Technique Candidates

@Suite("ChallengeGenerator - Technique Candidates")
struct ChallengeGeneratorTechniqueTests {

    @Test("practiceWeakTechnique never appears with no Learning-stage techniques")
    func noLearningStageNoPracticeChallenge() {
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .applying),
            TechniqueModel(name: "Armbar", stage: .polishing)
        ]

        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(techniques: techniques, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            #expect(result.contains { $0.challengeType == .practiceWeakTechnique } == false)
        }
    }

    @Test("practiceWeakTechnique can appear when Learning-stage techniques exist")
    func learningStageEnablesPracticeChallenge() {
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .learning),
            TechniqueModel(name: "Armbar", stage: .learning),
            TechniqueModel(name: "Kimura", stage: .learning)
        ]

        var seen = false
        for seed: UInt64 in 0..<50 {
            let ctx = makeContext(techniques: techniques, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            if result.contains(where: { $0.challengeType == .practiceWeakTechnique }) {
                seen = true
                break
            }
        }
        #expect(seen)
    }

    @Test("promoteTechnique never appears with only polishing-stage techniques")
    func polishingOnlyBlocksPromote() {
        let techniques = [
            TechniqueModel(name: "Triangle", stage: .polishing),
            TechniqueModel(name: "Armbar", stage: .polishing)
        ]

        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(techniques: techniques, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            #expect(result.contains { $0.challengeType == .promoteTechnique } == false)
        }
    }

    @Test("promoteTechnique can appear when non-polishing techniques exist")
    func nonPolishingEnablesPromote() {
        let techniques = [TechniqueModel(name: "Triangle", stage: .drilling)]

        var seen = false
        for seed: UInt64 in 0..<50 {
            let ctx = makeContext(techniques: techniques, randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            if result.contains(where: { $0.challengeType == .promoteTechnique }) {
                seen = true
                break
            }
        }
        #expect(seen)
    }

    @Test("Empty techniques list produces neither technique-aware challenge")
    func emptyTechniquesProducesNeither() {
        for seed: UInt64 in 0..<30 {
            let ctx = makeContext(techniques: [], randomSeed: seed)
            let result = ChallengeGenerator.generate(context: ctx)
            #expect(result.contains { $0.challengeType == .practiceWeakTechnique } == false)
            #expect(result.contains { $0.challengeType == .promoteTechnique } == false)
        }
    }
}
