import Testing
@testable import Waza

// MARK: - Session Achievements

@Suite("AchievementManager - Session Achievements") @MainActor
struct AchievementManagerSessionTests {

    func makeManager() -> AchievementManager {
        AchievementManager(services: MockAchievementServices(), logger: nil)
    }

    @Test("checkAndAward gives firstSession on the 1st session")
    func firstSession() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.firstSession))
        #expect(manager.isEarned(.firstSession))
    }

    @Test("checkAndAward does not give firstSession on the 2nd session")
    func firstSessionNotOnSecond() {
        // GIVEN
        let manager = makeManager()
        manager.checkAndAward(event: .sessionLogged(totalCount: 1, streakCount: 0), sessionStats: .empty, streakCount: 0)

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 2, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(!awarded.contains(.firstSession))
    }

    @Test("checkAndAward gives tenSessions on the 10th session")
    func tenSessions() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 10, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.tenSessions))
        #expect(manager.isEarned(.tenSessions))
    }

    @Test("checkAndAward does not give tenSessions before 10 sessions")
    func tenSessionsNotBefore() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 9, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(!awarded.contains(.tenSessions))
    }

    @Test("checkAndAward gives fiftySessions on the 50th session")
    func fiftySessions() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 50, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.fiftySessions))
        #expect(manager.isEarned(.fiftySessions))
    }

    @Test("checkAndAward gives hundredSessions on the 100th session")
    func hundredSessions() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 100, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.hundredSessions))
        #expect(manager.isEarned(.hundredSessions))
    }

    @Test("checkAndAward can give multiple session milestones in one event")
    func multipleMilestonesInOneEvent() {
        // GIVEN — a user logging session #100 has also crossed all lower milestones
        // but only #100 is awarded because totalCount == 100
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 100, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN — exactly hundredSessions fires (totalCount == 100, not 1/10/50)
        #expect(awarded.contains(.hundredSessions))
        #expect(!awarded.contains(.firstSession))
        #expect(!awarded.contains(.tenSessions))
        #expect(!awarded.contains(.fiftySessions))
    }
}

// MARK: - Streak Achievements

@Suite("AchievementManager - Streak Achievements") @MainActor
struct AchievementManagerStreakTests {

    func makeManager() -> AchievementManager {
        AchievementManager(services: MockAchievementServices(), logger: nil)
    }

    @Test("checkAndAward gives threeDayStreak at streak count of 3")
    func threeDayStreak() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 3),
            sessionStats: .empty,
            streakCount: 3
        )

        // THEN
        #expect(awarded.contains(.threeDayStreak))
        #expect(manager.isEarned(.threeDayStreak))
    }

    @Test("checkAndAward gives sevenDayStreak at streak count of 7")
    func sevenDayStreak() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 7),
            sessionStats: .empty,
            streakCount: 7
        )

        // THEN
        #expect(awarded.contains(.sevenDayStreak))
        #expect(manager.isEarned(.sevenDayStreak))
    }

    @Test("checkAndAward gives thirtyDayStreak at streak count of 30")
    func thirtyDayStreak() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 30),
            sessionStats: .empty,
            streakCount: 30
        )

        // THEN
        #expect(awarded.contains(.thirtyDayStreak))
        #expect(manager.isEarned(.thirtyDayStreak))
    }

    @Test("checkAndAward does not give streak achievements below thresholds")
    func streakBelowThreshold() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 2),
            sessionStats: .empty,
            streakCount: 2
        )

        // THEN
        #expect(!awarded.contains(.threeDayStreak))
        #expect(!awarded.contains(.sevenDayStreak))
        #expect(!awarded.contains(.thirtyDayStreak))
    }

    @Test("checkAndAward gives all streak milestones at once when crossing 30-day streak")
    func allStreakMilestonesAtOnce() {
        // GIVEN
        let manager = makeManager()

        // WHEN — streak = 30 triggers >=3, >=7, >=30
        let awarded = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 30),
            sessionStats: .empty,
            streakCount: 30
        )

        // THEN
        #expect(awarded.contains(.threeDayStreak))
        #expect(awarded.contains(.sevenDayStreak))
        #expect(awarded.contains(.thirtyDayStreak))
    }
}

// MARK: - Attendance Achievements

@Suite("AchievementManager - Attendance Achievements") @MainActor
struct AchievementManagerAttendanceTests {

    func makeManager() -> AchievementManager {
        AchievementManager(services: MockAchievementServices(), logger: nil)
    }

    @Test("checkAndAward gives firstClassCheckedIn on the 1st check-in")
    func firstCheckIn() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 1, isPerfectWeek: false, consecutivePerfectWeeks: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.firstClassCheckedIn))
        #expect(manager.isEarned(.firstClassCheckedIn))
    }

    @Test("checkAndAward gives fiveClassAttendance on the 5th check-in")
    func fiveCheckIns() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 5, isPerfectWeek: false, consecutivePerfectWeeks: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.fiveClassAttendance))
        #expect(manager.isEarned(.fiveClassAttendance))
    }

    @Test("checkAndAward gives twentyFiveClassAttendance on the 25th check-in")
    func twentyFiveCheckIns() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 25, isPerfectWeek: false, consecutivePerfectWeeks: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.twentyFiveClassAttendance))
        #expect(manager.isEarned(.twentyFiveClassAttendance))
    }

    @Test("checkAndAward gives perfectWeek when isPerfectWeek is true")
    func perfectWeek() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 3, isPerfectWeek: true, consecutivePerfectWeeks: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.perfectWeek))
        #expect(manager.isEarned(.perfectWeek))
    }

    @Test("checkAndAward does not give perfectWeek when isPerfectWeek is false")
    func noPerfectWeek() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 3, isPerfectWeek: false, consecutivePerfectWeeks: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(!awarded.contains(.perfectWeek))
    }

    @Test("checkAndAward gives fourWeekConsistency at 4 or more consecutive perfect weeks")
    func fourWeekConsistency() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 12, isPerfectWeek: true, consecutivePerfectWeeks: 4),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.fourWeekConsistency))
        #expect(manager.isEarned(.fourWeekConsistency))
    }

    @Test("checkAndAward does not give fourWeekConsistency below 4 consecutive weeks")
    func noFourWeekConsistencyBeforeThreshold() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .classCheckedIn(totalCount: 9, isPerfectWeek: true, consecutivePerfectWeeks: 3),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(!awarded.contains(.fourWeekConsistency))
    }
}

// MARK: - Special Achievements

@Suite("AchievementManager - Special Achievements") @MainActor
struct AchievementManagerSpecialTests {

    func makeManager() -> AchievementManager {
        AchievementManager(services: MockAchievementServices(), logger: nil)
    }

    @Test("checkAndAward gives firstGoalCompleted on goalCompleted event")
    func firstGoalCompleted() {
        // GIVEN
        let manager = makeManager()

        // WHEN
        let awarded = manager.checkAndAward(
            event: .goalCompleted(goalId: "goal-1"),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(awarded.contains(.firstGoalCompleted))
        #expect(manager.isEarned(.firstGoalCompleted))
    }

}

// MARK: - Idempotency

@Suite("AchievementManager - Idempotency") @MainActor
struct AchievementManagerIdempotencyTests {

    func makeManager() -> AchievementManager {
        AchievementManager(services: MockAchievementServices(), logger: nil)
    }

    @Test("The same achievement is never awarded twice")
    func noDuplicateAward() {
        // GIVEN
        let manager = makeManager()
        manager.checkAndAward(event: .sessionLogged(totalCount: 1, streakCount: 0), sessionStats: .empty, streakCount: 0)
        #expect(manager.earnedAchievements.count == 1)
        #expect(manager.isEarned(.firstSession))

        // WHEN — same milestone triggered again
        let secondAward = manager.checkAndAward(
            event: .sessionLogged(totalCount: 1, streakCount: 0),
            sessionStats: .empty,
            streakCount: 0
        )

        // THEN
        #expect(secondAward.isEmpty)
        #expect(manager.earnedAchievements.count == 1)
    }

    @Test("isEarned returns true after an achievement is awarded")
    func isEarnedTrue() {
        // GIVEN
        let manager = makeManager()
        #expect(!manager.isEarned(.firstSession))

        // WHEN
        manager.checkAndAward(event: .sessionLogged(totalCount: 1, streakCount: 0), sessionStats: .empty, streakCount: 0)

        // THEN
        #expect(manager.isEarned(.firstSession))
    }

    @Test("isEarned returns false for achievements not yet earned")
    func isEarnedFalse() {
        // GIVEN
        let manager = makeManager()

        // WHEN / THEN — nothing has been awarded
        #expect(!manager.isEarned(.hundredSessions))
        #expect(!manager.isEarned(.thirtyDayStreak))
        #expect(!manager.isEarned(.firstGoalCompleted))
    }

    @Test("clearAll removes all earned achievements")
    func clearAll() {
        // GIVEN
        let manager = makeManager()
        manager.checkAndAward(event: .sessionLogged(totalCount: 1, streakCount: 0), sessionStats: .empty, streakCount: 0)
        manager.checkAndAward(event: .goalCompleted(goalId: "g1"), sessionStats: .empty, streakCount: 0)
        #expect(!manager.earnedAchievements.isEmpty)

        // WHEN
        manager.clearAll()

        // THEN
        #expect(manager.earnedAchievements.isEmpty)
        #expect(!manager.isEarned(.firstSession))
        #expect(!manager.isEarned(.firstGoalCompleted))
    }
}
