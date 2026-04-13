import SwiftUI

extension CoreInteractor {

    // MARK: ChallengeManager

    var currentChallenges: [WeeklyChallengeModel] {
        challengeManager.currentChallenges
    }

    var completedChallengeCount: Int {
        challengeManager.completedCount
    }

    func generateChallengesIfNeeded() {
        let allFocusAreas = Set(sessionManager.sessions.flatMap(\.focusAreas))
        let recentFocusAreas = recentFocusAreasForChallenges(withinDays: 30)
        let context = ChallengeGenerator.GenerationContext(
            sessions: sessionManager.sessions,
            gyms: classScheduleManager.gyms,
            allFocusAreas: allFocusAreas,
            recentFocusAreas: recentFocusAreas,
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            trainingGoalPerWeek: userManager.currentUser?.trainingGoalPerWeek
        )
        challengeManager.generateIfNeeded(context: context)
    }

    func evaluateChallenges(session: BJJSessionModel) -> [WeeklyChallengeModel] {
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }
        let weekSessions = sessionManager.sessions.filter { $0.date >= weekStart && $0.date < weekEnd }
        return challengeManager.evaluate(
            session: session,
            allSessionsThisWeek: weekSessions,
            gyms: classScheduleManager.gyms
        )
    }

    // MARK: - Private

    private func recentFocusAreasForChallenges(withinDays days: Int) -> Set<String> {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recent = sessionManager.sessions.filter { $0.date >= cutoff }
        return Set(recent.flatMap(\.focusAreas))
    }

}
