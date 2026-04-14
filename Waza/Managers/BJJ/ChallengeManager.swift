import Foundation

@Observable
@MainActor
class ChallengeManager {
    private let localService: ChallengeLocalService
    private(set) var challenges: [WeeklyChallengeModel] = []

    init(localService: ChallengeLocalService) {
        self.localService = localService
        refresh()
    }

    // MARK: - Lifecycle

    func logIn(userId: String) {
        refresh()
    }

    func logOut() { }

    // MARK: - Read

    func refresh() {
        challenges = localService.getChallenges()
    }

    var currentChallenges: [WeeklyChallengeModel] {
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        return challenges.filter {
            Calendar.current.isDate($0.weekStartDate, inSameDayAs: weekStart)
        }
    }

    var completedCount: Int {
        currentChallenges.filter(\.isCompleted).count
    }

    // MARK: - Generation

    /// Generates challenges for the current week if none exist yet. Idempotent.
    ///
    /// When `requireSessionData` is true, generation is skipped if `context.sessions` is empty.
    /// This guards against the case where a returning user's sessions haven't loaded yet (offline
    /// start, fresh install, slow sync). Callers are expected to retry on the next refresh.
    /// For new users, pass `requireSessionData: false` so beginner defaults generate immediately.
    func generateIfNeeded(
        context: ChallengeGenerator.GenerationContext,
        requireSessionData: Bool = false
    ) {
        guard currentChallenges.isEmpty else { return }
        if requireSessionData && context.sessions.isEmpty { return }
        let generated = ChallengeGenerator.generate(context: context)
        for challenge in generated {
            try? localService.create(challenge)
        }
        refresh()
    }

    // MARK: - Evaluation

    /// Re-scans all sessions for the current week and updates challenge progress.
    /// Returns the array of challenges that became newly completed during this call.
    @discardableResult
    func evaluate(
        session: BJJSessionModel,
        allSessionsThisWeek: [BJJSessionModel],
        gyms: [GymLocationModel],
        techniques: [TechniqueModel] = [],
        weekStart: Date = WeeklyChallengeModel.currentWeekStart()
    ) -> [WeeklyChallengeModel] {
        var newlyCompleted: [WeeklyChallengeModel] = []

        for var challenge in currentChallenges {
            guard !challenge.isCompleted else { continue }

            let newValue = computeCurrentValue(
                for: challenge,
                allSessionsThisWeek: allSessionsThisWeek,
                gyms: gyms,
                techniques: techniques,
                weekStart: weekStart
            )
            challenge.currentValue = newValue

            if newValue >= challenge.targetValue {
                challenge.isCompleted = true
                challenge.completedDate = Date()
                newlyCompleted.append(challenge)
            }

            try? localService.update(challenge)
        }

        refresh()

        return newlyCompleted
    }

    // MARK: - Wipe

    func clearAll() {
        try? localService.deleteAll()
        challenges = []
    }

    func seedMockDataIfEmpty() {
        guard challenges.isEmpty else { return }
        for model in WeeklyChallengeModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }

    // MARK: - Private Evaluation Logic

    private func computeCurrentValue(
        for challenge: WeeklyChallengeModel,
        allSessionsThisWeek: [BJJSessionModel],
        gyms: [GymLocationModel],
        techniques: [TechniqueModel],
        weekStart: Date
    ) -> Int {
        switch challenge.challengeType {
        case .trainXTimes:       return allSessionsThisWeek.count
        case .logSessionType:    return evaluateSessionType(challenge: challenge, sessions: allSessionsThisWeek)
        case .newFocusArea:      return evaluateNewFocusArea(challenge: challenge, sessions: allSessionsThisWeek)
        case .trainAtDifferentGym: return evaluateDifferentGym(challenge: challenge, sessions: allSessionsThisWeek)
        case .logMoodBothWays:   return evaluateMood(sessions: allSessionsThisWeek)
        case .miniStreak:        return maxConsecutiveDays(from: allSessionsThisWeek)
        case .logFullReflection: return evaluateFullReflection(sessions: allSessionsThisWeek)
        case .trainDuration:
            // Threshold minutes live in metadata; targetValue is 1 (binary completion).
            let thresholdMinutes = Double(challenge.metadata.flatMap(Int.init) ?? 90)
            let thresholdSeconds = thresholdMinutes * 60.0
            let hasLong = allSessionsThisWeek.contains { $0.duration >= thresholdSeconds }
            return hasLong ? 1 : 0
        case .practiceWeakTechnique:
            return evaluatePracticeWeakTechnique(sessions: allSessionsThisWeek, techniques: techniques)
        case .promoteTechnique:
            return evaluatePromoteTechnique(techniques: techniques, weekStart: weekStart)
        }
    }

    private func evaluatePracticeWeakTechnique(
        sessions: [BJJSessionModel],
        techniques: [TechniqueModel]
    ) -> Int {
        let learningNames = Set(
            techniques.filter { $0.stage == .learning }.map { $0.name.lowercased() }
        )
        guard !learningNames.isEmpty else { return 0 }
        return sessions.contains { session in
            session.focusAreas.contains { learningNames.contains($0.lowercased()) }
        } ? 1 : 0
    }

    private func evaluatePromoteTechnique(
        techniques: [TechniqueModel],
        weekStart: Date
    ) -> Int {
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else {
            return 0
        }
        return techniques.contains { technique in
            guard let changed = technique.lastStageChangeDate else { return false }
            return changed >= weekStart && changed < weekEnd
        } ? 1 : 0
    }

    private func evaluateSessionType(challenge: WeeklyChallengeModel, sessions: [BJJSessionModel]) -> Int {
        guard let typeRaw = challenge.metadata,
              let targetType = SessionType(rawValue: typeRaw) else { return 0 }
        return sessions.filter { $0.sessionType == targetType }.count
    }

    private func evaluateNewFocusArea(challenge: WeeklyChallengeModel, sessions: [BJJSessionModel]) -> Int {
        let recentAreas: Set<String>
        if let meta = challenge.metadata, !meta.isEmpty {
            recentAreas = Set(meta.split(separator: ",").map { String($0) })
        } else {
            recentAreas = []
        }
        return sessions.contains { $0.focusAreas.contains { !recentAreas.contains($0) } } ? 1 : 0
    }

    private func evaluateDifferentGym(challenge: WeeklyChallengeModel, sessions: [BJJSessionModel]) -> Int {
        let primary = challenge.metadata
        return sessions.contains { session in
            guard let academy = session.academy, !academy.isEmpty else { return false }
            guard let primary else { return true }
            return academy.caseInsensitiveCompare(primary) != .orderedSame
        } ? 1 : 0
    }

    private func evaluateMood(sessions: [BJJSessionModel]) -> Int {
        sessions.contains { $0.preSessionMood != nil && $0.postSessionMood != nil } ? 1 : 0
    }

    private func evaluateFullReflection(sessions: [BJJSessionModel]) -> Int {
        sessions.contains { session in
            [session.notes, session.whatWorkedWell, session.needsImprovement, session.keyInsights]
                .allSatisfy { ($0 ?? "").trimmingCharacters(in: .whitespaces).isEmpty == false }
        } ? 1 : 0
    }

    private func maxConsecutiveDays(from sessions: [BJJSessionModel]) -> Int {
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
}
