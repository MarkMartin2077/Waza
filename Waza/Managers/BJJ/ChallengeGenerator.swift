import Foundation

// MARK: - Challenge Generator
//
// Pure static enum — zero external dependencies. All input passed as parameters.
// This design makes the entire generation algorithm unit-testable without mocks.

enum ChallengeGenerator {

    // MARK: - Generation Context

    struct GenerationContext {
        let sessions: [BJJSessionModel]
        let gyms: [GymLocationModel]
        let allFocusAreas: Set<String>
        let recentFocusAreas: Set<String>   // focus areas from last 30 days
        let techniques: [TechniqueModel]
        let weekStartDate: Date
        let trainingGoalPerWeek: Int?
        let randomSeed: UInt64              // pass a fixed seed in tests; default is random

        init(
            sessions: [BJJSessionModel],
            gyms: [GymLocationModel],
            allFocusAreas: Set<String>,
            recentFocusAreas: Set<String>,
            techniques: [TechniqueModel] = [],
            weekStartDate: Date,
            trainingGoalPerWeek: Int? = nil,
            randomSeed: UInt64 = UInt64.random(in: 0...UInt64.max)
        ) {
            self.sessions = sessions
            self.gyms = gyms
            self.allFocusAreas = allFocusAreas
            self.recentFocusAreas = recentFocusAreas
            self.techniques = techniques
            self.weekStartDate = weekStartDate
            self.trainingGoalPerWeek = trainingGoalPerWeek
            self.randomSeed = randomSeed
        }
    }

    // MARK: - Candidate

    private struct ChallengeCandidate {
        let type: ChallengeType
        let title: String
        let targetValue: Int
        let metadata: String?
        let weight: Double
        let category: ChallengeCategory
    }

    // MARK: - Generate

    static func generate(context: GenerationContext) -> [WeeklyChallengeModel] {
        let candidates = buildCandidates(context: context)
        guard !candidates.isEmpty else { return [] }

        let picked = pickWithVariety(candidates: candidates, count: 3, seed: context.randomSeed)

        return picked.map { candidate in
            WeeklyChallengeModel(
                weekStartDate: context.weekStartDate,
                challengeType: candidate.type,
                title: candidate.title,
                targetValue: candidate.targetValue,
                metadata: candidate.metadata
            )
        }
    }

    // MARK: - Build Candidates

    private static func buildCandidates(context: GenerationContext) -> [ChallengeCandidate] {
        let recent = recentSessions(context.sessions, withinDays: 30)
        var candidates: [ChallengeCandidate] = []
        candidates.append(contentsOf: frequencyCandidates(context: context, recentSessions: recent))
        candidates.append(contentsOf: explorationCandidates(context: context, recentSessions: recent))
        candidates.append(contentsOf: qualityCandidates(recentSessions: recent))
        candidates.append(contentsOf: intensityCandidates(allSessions: context.sessions))
        candidates.append(contentsOf: techniqueCandidates(context: context))
        return candidates
    }

    private static func techniqueCandidates(context: GenerationContext) -> [ChallengeCandidate] {
        var result: [ChallengeCandidate] = []

        let learningStage = context.techniques.filter { $0.stage == .learning }
        if !learningStage.isEmpty {
            // Weight grows with how many learning-stage techniques the user has.
            let weight = min(0.9, 0.4 + Double(learningStage.count) * 0.1)
            result.append(ChallengeCandidate(
                type: .practiceWeakTechnique,
                title: "Train a technique you're still learning",
                targetValue: 1,
                metadata: nil,
                weight: weight,
                category: .technique
            ))
        }

        // Promotable = any non-polishing technique the user has.
        let promotable = context.techniques.filter { $0.stage != .polishing }
        if !promotable.isEmpty {
            result.append(ChallengeCandidate(
                type: .promoteTechnique,
                title: "Promote a technique to the next stage",
                targetValue: 1,
                metadata: nil,
                weight: 0.6,
                category: .technique
            ))
        }

        return result
    }

    private static func frequencyCandidates(context: GenerationContext, recentSessions: [BJJSessionModel]) -> [ChallengeCandidate] {
        var result: [ChallengeCandidate] = []

        let target = context.trainingGoalPerWeek ?? 3
        let avgPerWeek = averageSessionsPerWeek(from: recentSessions)
        let trainWeight = max(0.3, 1.0 - (avgPerWeek / max(Double(target), 1.0)))
        result.append(ChallengeCandidate(
            type: .trainXTimes, title: "Train \(target) times this week",
            targetValue: target, metadata: nil, weight: trainWeight, category: .frequency
        ))

        let maxConsecutive = maxConsecutiveDays(from: recentSessions)
        result.append(ChallengeCandidate(
            type: .miniStreak, title: "Train 2 days in a row",
            targetValue: 2, metadata: nil, weight: maxConsecutive < 2 ? 0.9 : 0.4, category: .frequency
        ))

        return result
    }

    private static func explorationCandidates(context: GenerationContext, recentSessions: [BJJSessionModel]) -> [ChallengeCandidate] {
        var result: [ChallengeCandidate] = []

        let typeCounts = sessionTypeCounts(from: recentSessions)
        if let leastUsed = leastUsedSessionType(typeCounts: typeCounts, totalCount: recentSessions.count), !recentSessions.isEmpty {
            let ratio = Double(typeCounts[leastUsed] ?? 0) / Double(max(recentSessions.count, 1))
            result.append(ChallengeCandidate(
                type: .logSessionType, title: "Log a \(leastUsed.displayName) session",
                targetValue: 1, metadata: leastUsed.rawValue, weight: max(0.2, 1.0 - ratio), category: .exploration
            ))
        }

        if !context.allFocusAreas.isEmpty {
            let repetitiveRatio = Double(context.recentFocusAreas.count) / Double(max(context.allFocusAreas.count, 1))
            result.append(ChallengeCandidate(
                type: .newFocusArea, title: "Try a technique you haven't trained recently",
                targetValue: 1, metadata: context.recentFocusAreas.joined(separator: ","),
                weight: repetitiveRatio < 0.5 ? 0.9 : 0.4, category: .exploration
            ))
        }

        let distinctAcademies = Set(context.sessions.compactMap(\.academy)).filter { !$0.isEmpty }
        if context.gyms.count >= 2 || distinctAcademies.count >= 2 {
            result.append(ChallengeCandidate(
                type: .trainAtDifferentGym, title: "Train at a different gym",
                targetValue: 1, metadata: mostFrequentAcademy(from: recentSessions),
                weight: 0.8, category: .exploration
            ))
        }

        return result
    }

    private static func qualityCandidates(recentSessions: [BJJSessionModel]) -> [ChallengeCandidate] {
        var result: [ChallengeCandidate] = []

        let bothMoodsCount = recentSessions.filter { $0.preSessionMood != nil && $0.postSessionMood != nil }.count
        let bothMoodsRatio = recentSessions.isEmpty ? 0.0 : Double(bothMoodsCount) / Double(recentSessions.count)
        result.append(ChallengeCandidate(
            type: .logMoodBothWays, title: "Rate your mood before & after a session",
            targetValue: 1, metadata: nil, weight: max(0.2, 1.0 - bothMoodsRatio), category: .quality
        ))

        let fullCount = recentSessions.filter { hasFullReflection($0) }.count
        let fullRatio = recentSessions.isEmpty ? 0.0 : Double(fullCount) / Double(recentSessions.count)
        result.append(ChallengeCandidate(
            type: .logFullReflection, title: "Write a full session reflection",
            targetValue: 1, metadata: nil, weight: max(0.2, 1.0 - fullRatio), category: .quality
        ))

        return result
    }

    private static func intensityCandidates(allSessions: [BJJSessionModel]) -> [ChallengeCandidate] {
        guard allSessions.contains(where: { $0.duration >= 3600 }) else { return [] }
        // targetValue is 1 (binary complete); metadata holds the duration threshold in minutes.
        return [ChallengeCandidate(
            type: .trainDuration, title: "Log a 90+ minute session",
            targetValue: 1, metadata: "90", weight: 0.6, category: .intensity
        )]
    }

    // MARK: - Variety-Enforced Weighted Selection

    /// Picks up to `count` candidates ensuring at most 1 per category before repeating.
    private static func pickWithVariety(
        candidates: [ChallengeCandidate],
        count: Int,
        seed: UInt64
    ) -> [ChallengeCandidate] {
        var rng = SeededRNG(seed: seed)
        var remaining = candidates
        var picked: [ChallengeCandidate] = []
        var usedCategories: Set<String> = []

        // First pass: pick one per category
        for _ in 0..<count {
            guard !remaining.isEmpty else { break }
            let pool = remaining.filter { !usedCategories.contains($0.category.rawValue) }
            let source = pool.isEmpty ? remaining : pool
            if let chosen = weightedRandom(from: source, rng: &rng) {
                picked.append(chosen)
                usedCategories.insert(chosen.category.rawValue)
                remaining.removeAll { $0.type == chosen.type }
            }
        }

        // Second pass: fill remaining slots from whatever is left (all categories allowed)
        while picked.count < count, !remaining.isEmpty {
            if let chosen = weightedRandom(from: remaining, rng: &rng) {
                picked.append(chosen)
                remaining.removeAll { $0.type == chosen.type }
            }
        }

        return picked
    }

    // MARK: - Weighted Random

    private static func weightedRandom(
        from candidates: [ChallengeCandidate],
        rng: inout SeededRNG
    ) -> ChallengeCandidate? {
        guard !candidates.isEmpty else { return nil }
        let totalWeight = candidates.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return candidates.first }
        var randomValue = Double(rng.next()) / Double(UInt64.max) * totalWeight
        for candidate in candidates {
            randomValue -= candidate.weight
            if randomValue <= 0 { return candidate }
        }
        return candidates.last
    }

    // MARK: - Statistical Helpers

    private static func recentSessions(_ sessions: [BJJSessionModel], withinDays days: Int) -> [BJJSessionModel] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return sessions.filter { $0.date >= cutoff }
    }

    private static func averageSessionsPerWeek(from sessions: [BJJSessionModel]) -> Double {
        guard !sessions.isEmpty else { return 0 }
        guard let earliest = sessions.map(\.date).min() else { return 0 }
        let weeks = max(1.0, Calendar.current.dateComponents([.weekOfYear], from: earliest, to: Date()).weekOfYear.map { Double($0) } ?? 1.0)
        return Double(sessions.count) / weeks
    }

    private static func sessionTypeCounts(from sessions: [BJJSessionModel]) -> [SessionType: Int] {
        var counts: [SessionType: Int] = [:]
        for session in sessions {
            counts[session.sessionType, default: 0] += 1
        }
        return counts
    }

    private static func leastUsedSessionType(
        typeCounts: [SessionType: Int],
        totalCount: Int
    ) -> SessionType? {
        guard totalCount > 0 else { return nil }
        let usedTypes = Set(typeCounts.keys)
        // Prefer completely unused types first
        let unused = SessionType.allCases.filter { !usedTypes.contains($0) && $0 != .competition }
        if let pick = unused.first { return pick }
        // Otherwise pick the least used (excluding competition as it's hard to control)
        return typeCounts
            .filter { $0.key != .competition }
            .min { $0.value < $1.value }?
            .key
    }

    private static func mostFrequentAcademy(from sessions: [BJJSessionModel]) -> String? {
        var counts: [String: Int] = [:]
        for session in sessions {
            guard let academy = session.academy, !academy.isEmpty else { continue }
            counts[academy, default: 0] += 1
        }
        return counts.max { $0.value < $1.value }?.key
    }

    private static func maxConsecutiveDays(from sessions: [BJJSessionModel]) -> Int {
        let calendar = Calendar.current
        let trainingDays = Set(sessions.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !trainingDays.isEmpty else { return 0 }
        var maxRun = 1
        var currentRun = 1
        for idx in 1..<trainingDays.count {
            let diff = calendar.dateComponents([.day], from: trainingDays[idx - 1], to: trainingDays[idx]).day ?? 0
            if diff == 1 {
                currentRun += 1
                maxRun = max(maxRun, currentRun)
            } else {
                currentRun = 1
            }
        }
        return maxRun
    }

    private static func hasFullReflection(_ session: BJJSessionModel) -> Bool {
        let fields = [session.notes, session.whatWorkedWell, session.needsImprovement, session.keyInsights]
        return fields.allSatisfy { ($0 ?? "").trimmingCharacters(in: .whitespaces).isEmpty == false }
    }
}

// MARK: - Seeded RNG (LCG — simple, deterministic, no Foundation dependency)

private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed &+ 1
    }

    mutating func next() -> UInt64 {
        // Knuth multiplicative hash
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
