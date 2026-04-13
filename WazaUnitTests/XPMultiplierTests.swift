import Testing
import Foundation
@testable import Waza

// MARK: - Streak Bonus Tests

@Suite("XPMultiplierCalculator - Streak Bonus")
struct XPMultiplierStreakTests {

    @Test("No bonus below 3 days")
    func noStreakBonus() {
        #expect(XPMultiplierCalculator.streakBonus(forDays: 0) == 0.0)
        #expect(XPMultiplierCalculator.streakBonus(forDays: 1) == 0.0)
        #expect(XPMultiplierCalculator.streakBonus(forDays: 2) == 0.0)
    }

    @Test("3-6 days gives +25%")
    func threeToSixDays() {
        #expect(XPMultiplierCalculator.streakBonus(forDays: 3) == 0.25)
        #expect(XPMultiplierCalculator.streakBonus(forDays: 6) == 0.25)
    }

    @Test("7-13 days gives +50%")
    func sevenToThirteenDays() {
        #expect(XPMultiplierCalculator.streakBonus(forDays: 7) == 0.5)
        #expect(XPMultiplierCalculator.streakBonus(forDays: 13) == 0.5)
    }

    @Test("14-29 days gives +75%")
    func fourteenToTwentyNineDays() {
        #expect(XPMultiplierCalculator.streakBonus(forDays: 14) == 0.75)
        #expect(XPMultiplierCalculator.streakBonus(forDays: 29) == 0.75)
    }

    @Test("30+ days gives +100%")
    func thirtyPlusDays() {
        #expect(XPMultiplierCalculator.streakBonus(forDays: 30) == 1.0)
        #expect(XPMultiplierCalculator.streakBonus(forDays: 100) == 1.0)
    }
}

// MARK: - Multiplier Calculation Tests

@Suite("XPMultiplierCalculator - Calculate")
struct XPMultiplierCalculateTests {

    @Test("No boosts when streak is low and no perfect week")
    func noBoosts() {
        let result = XPMultiplierCalculator.calculate(streakDays: 1, sessionsLastWeek: 1, randomRoll: 0.99)
        #expect(result.totalMultiplier == 1.0)
        #expect(result.hasBoost == false)
        #expect(result.components.isEmpty)
    }

    @Test("Streak component added for 7-day streak")
    func streakOnly() {
        let result = XPMultiplierCalculator.calculate(streakDays: 7, sessionsLastWeek: 0, randomRoll: 0.99)
        #expect(result.baseMultiplier == 1.5)
        #expect(result.totalMultiplier == 1.5)
        #expect(result.components.count == 1)
        #expect(result.components.first?.reason == .streak)
    }

    @Test("Perfect week adds +0.25x")
    func perfectWeekOnly() {
        let result = XPMultiplierCalculator.calculate(streakDays: 0, sessionsLastWeek: 3, randomRoll: 0.99)
        #expect(result.baseMultiplier == 1.25)
        #expect(result.totalMultiplier == 1.25)
        #expect(result.components.contains { $0.reason == .perfectWeek })
    }

    @Test("Perfect week requires meeting the target")
    func belowPerfectWeekTarget() {
        let result = XPMultiplierCalculator.calculate(streakDays: 0, sessionsLastWeek: 2, randomRoll: 0.99)
        #expect(!result.components.contains { $0.reason == .perfectWeek })
    }

    @Test("Fire round triggers below 15% threshold")
    func fireRoundTriggers() {
        let result = XPMultiplierCalculator.calculate(streakDays: 0, sessionsLastWeek: 0, randomRoll: 0.10)
        #expect(result.isFireRound)
        #expect(result.totalMultiplier == 2.0)
    }

    @Test("Fire round does not trigger above 15% threshold")
    func fireRoundDoesNotTrigger() {
        let result = XPMultiplierCalculator.calculate(streakDays: 0, sessionsLastWeek: 0, randomRoll: 0.20)
        #expect(!result.isFireRound)
    }

    @Test("Streak + perfect week stack additively")
    func streakPlusPerfectWeek() {
        let result = XPMultiplierCalculator.calculate(streakDays: 7, sessionsLastWeek: 4, randomRoll: 0.99)
        // 1.0 + 0.5 (streak) + 0.25 (perfect week) = 1.75
        #expect(result.baseMultiplier == 1.75)
        #expect(result.totalMultiplier == 1.75)
        #expect(result.components.count == 2)
    }

    @Test("Fire round doubles the full multiplier")
    func fireRoundDoubles() {
        let result = XPMultiplierCalculator.calculate(streakDays: 7, sessionsLastWeek: 3, randomRoll: 0.05)
        // base = 1.0 + 0.5 + 0.25 = 1.75, fire round = 1.75 * 2 = 3.5
        #expect(result.baseMultiplier == 1.75)
        #expect(result.totalMultiplier == 3.5)
        #expect(result.isFireRound)
    }

    @Test("Maximum multiplier is 30-day streak + perfect week + fire round")
    func maximumMultiplier() {
        let result = XPMultiplierCalculator.calculate(streakDays: 30, sessionsLastWeek: 5, randomRoll: 0.01)
        // base = 1.0 + 1.0 + 0.25 = 2.25, fire round = 2.25 * 2 = 4.5
        #expect(result.totalMultiplier == 4.5)
    }
}

// MARK: - Apply Tests

@Suite("XPMultiplierCalculator - Apply")
struct XPMultiplierApplyTests {

    @Test("No boost returns base points unchanged")
    func noBoostUnchanged() {
        let result = XPMultiplierResult.none
        #expect(XPMultiplierCalculator.apply(result, toBasePoints: 18) == 18)
    }

    @Test("1.5x multiplier on 18 base = 27")
    func streakMultiplied() {
        let result = XPMultiplierCalculator.calculate(streakDays: 7, sessionsLastWeek: 0, randomRoll: 0.99)
        #expect(XPMultiplierCalculator.apply(result, toBasePoints: 18) == 27)
    }

    @Test("Rounding works correctly for odd multipliers")
    func roundingCorrect() {
        let result = XPMultiplierCalculator.calculate(streakDays: 3, sessionsLastWeek: 0, randomRoll: 0.99)
        // 1.25x on 13 = 16.25, rounds to 16
        #expect(XPMultiplierCalculator.apply(result, toBasePoints: 13) == 16)
    }

    @Test("Fire round on max session = expected ceiling")
    func fireRoundOnMaxSession() {
        let result = XPMultiplierCalculator.calculate(streakDays: 30, sessionsLastWeek: 5, randomRoll: 0.01)
        // 33 * 4.5 = 148.5 rounds to 149
        #expect(XPMultiplierCalculator.apply(result, toBasePoints: 33) == 149)
    }
}

// MARK: - Display Text Tests

@Suite("XPMultiplierResult - Display")
struct XPMultiplierDisplayTests {

    @Test("No boost has nil display text")
    func noBoostNilDisplay() {
        #expect(XPMultiplierResult.none.displayText == nil)
    }

    @Test("Single component shows multiplier and reason")
    func singleComponent() {
        let result = XPMultiplierCalculator.calculate(streakDays: 7, sessionsLastWeek: 0, randomRoll: 0.99)
        let text = result.displayText
        #expect(text?.contains("1.5x") == true)
        #expect(text?.contains("Streak") == true)
    }

    @Test("Multiple components joined with +")
    func multipleComponents() {
        let result = XPMultiplierCalculator.calculate(streakDays: 7, sessionsLastWeek: 3, randomRoll: 0.99)
        let text = result.displayText
        #expect(text?.contains("Streak") == true)
        #expect(text?.contains("Perfect Week") == true)
        #expect(text?.contains("+") == true)
    }

    @Test("Fire round included in display")
    func fireRoundDisplay() {
        let result = XPMultiplierCalculator.calculate(streakDays: 0, sessionsLastWeek: 0, randomRoll: 0.05)
        let text = result.displayText
        #expect(text?.contains("Fire Round") == true)
        #expect(text?.contains("2x") == true)
    }
}
