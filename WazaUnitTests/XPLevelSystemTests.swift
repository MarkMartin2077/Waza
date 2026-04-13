import Testing
import Foundation
@testable import Waza

// MARK: - XPLevelSystem Tests

@Suite("XPLevelSystem - Level Calculation")
struct XPLevelCalculationTests {

    @Test("Zero XP is level 1")
    func zeroXPIsLevel1() {
        #expect(XPLevelSystem.level(forXP: 0) == 1)
    }

    @Test("Negative XP is level 1")
    func negativeXPIsLevel1() {
        #expect(XPLevelSystem.level(forXP: -100) == 1)
    }

    @Test("XP just below level 2 threshold stays at level 1")
    func justBelowLevel2() {
        let threshold = XPLevelSystem.xpRequired(forLevel: 2)
        #expect(XPLevelSystem.level(forXP: threshold - 1) == 1)
    }

    @Test("XP exactly at level 2 threshold is level 2")
    func exactlyLevel2() {
        let threshold = XPLevelSystem.xpRequired(forLevel: 2)
        #expect(XPLevelSystem.level(forXP: threshold) == 2)
    }

    @Test("Level 1 requires 0 XP")
    func level1Requires0() {
        #expect(XPLevelSystem.xpRequired(forLevel: 1) == 0)
    }

    @Test("XP thresholds are strictly increasing")
    func thresholdsIncreasing() {
        for lvl in 1..<50 {
            let current = XPLevelSystem.xpRequired(forLevel: lvl)
            let next = XPLevelSystem.xpRequired(forLevel: lvl + 1)
            #expect(next > current, "Level \(lvl + 1) threshold (\(next)) should exceed level \(lvl) (\(current))")
        }
    }

    @Test("High XP produces levels beyond 40")
    func highXPBeyond40() {
        let totalXP = XPLevelSystem.xpRequired(forLevel: 45)
        #expect(XPLevelSystem.level(forXP: totalXP) == 45)
    }
}

// MARK: - League & Sub-Rank Tests

@Suite("XPLevelSystem - Leagues & Sub-Ranks")
struct XPLeagueTests {

    @Test("Levels 1-5 are Rookie")
    func rookieLeague() {
        for lvl in 1...5 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .rookie)
        }
    }

    @Test("Levels 6-10 are Scrapper")
    func scrapperLeague() {
        for lvl in 6...10 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .scrapper)
        }
    }

    @Test("Levels 11-15 are Grappler")
    func grapplerLeague() {
        for lvl in 11...15 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .grappler)
        }
    }

    @Test("Levels 16-20 are Contender")
    func contenderLeague() {
        for lvl in 16...20 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .contender)
        }
    }

    @Test("Levels 21-25 are Adept")
    func adeptLeague() {
        for lvl in 21...25 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .adept)
        }
    }

    @Test("Levels 26-30 are Ace")
    func aceLeague() {
        for lvl in 26...30 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .ace)
        }
    }

    @Test("Levels 31-35 are Vanguard")
    func vanguardLeague() {
        for lvl in 31...35 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .vanguard)
        }
    }

    @Test("Levels 36-40 are Grandmaster")
    // swiftlint:disable:next inclusive_language
    func grandmasterLeague() {
        for lvl in 36...40 {
            #expect(XPLevelSystem.league(forLevel: lvl) == .grandmaster)
        }
    }

    @Test("Levels above 40 are Legend")
    func legendLeague() {
        #expect(XPLevelSystem.league(forLevel: 41) == .legend)
        #expect(XPLevelSystem.league(forLevel: 50) == .legend)
    }

    @Test("Sub-rank cycles 1 through 5 within each league")
    func subRankCycles() {
        #expect(XPLevelSystem.subRank(forLevel: 1) == 1)
        #expect(XPLevelSystem.subRank(forLevel: 5) == 5)
        #expect(XPLevelSystem.subRank(forLevel: 6) == 1)
        #expect(XPLevelSystem.subRank(forLevel: 10) == 5)
        #expect(XPLevelSystem.subRank(forLevel: 40) == 5)
    }

    @Test("Sub-rank is nil for Legend levels")
    func subRankNilForLegend() {
        #expect(XPLevelSystem.subRank(forLevel: 41) == nil)
        #expect(XPLevelSystem.subRank(forLevel: 50) == nil)
    }
}

// MARK: - Title Tests

@Suite("XPLevelSystem - Titles")
struct XPTitleTests {

    @Test("Title includes league name and sub-rank number")
    func titleFormat() {
        #expect(XPLevelSystem.title(forLevel: 1) == "Rookie 1")
        #expect(XPLevelSystem.title(forLevel: 5) == "Rookie 5")
        #expect(XPLevelSystem.title(forLevel: 6) == "Scrapper 1")
        #expect(XPLevelSystem.title(forLevel: 21) == "Adept 1")
        #expect(XPLevelSystem.title(forLevel: 40) == "Grandmaster 5")
    }

    @Test("Legend title has no sub-rank number")
    func legendTitle() {
        #expect(XPLevelSystem.title(forLevel: 41) == "Legend")
        #expect(XPLevelSystem.title(forLevel: 50) == "Legend")
    }
}

// MARK: - Progress Tests

@Suite("XPLevelSystem - Progress")
struct XPProgressTests {

    @Test("Progress is 0.0 at the start of a level")
    func progressAtLevelStart() {
        let levelXP = XPLevelSystem.xpRequired(forLevel: 5)
        let progress = XPLevelSystem.progressToNextLevel(forXP: levelXP)
        #expect(progress >= 0.0 && progress <= 0.01)
    }

    @Test("Progress is close to 1.0 just before next level")
    func progressNearEnd() {
        let nextXP = XPLevelSystem.xpRequired(forLevel: 6)
        let progress = XPLevelSystem.progressToNextLevel(forXP: nextXP - 1)
        #expect(progress > 0.9)
    }

    @Test("Progress is approximately 0.5 at midpoint")
    func progressMidpoint() {
        let start = XPLevelSystem.xpRequired(forLevel: 10)
        let end = XPLevelSystem.xpRequired(forLevel: 11)
        let mid = start + (end - start) / 2
        let progress = XPLevelSystem.progressToNextLevel(forXP: mid)
        #expect(progress > 0.4 && progress < 0.6)
    }

    @Test("Zero XP has zero progress")
    func zeroXPZeroProgress() {
        let progress = XPLevelSystem.progressToNextLevel(forXP: 0)
        #expect(progress >= 0.0 && progress <= 0.01)
    }
}

// MARK: - Level Up Detection Tests

@Suite("XPLevelSystem - Level Up Detection")
struct XPLevelUpTests {

    @Test("Crossing a level boundary is detected")
    func levelUpDetected() {
        let lvl5XP = XPLevelSystem.xpRequired(forLevel: 5)
        let lvl6XP = XPLevelSystem.xpRequired(forLevel: 6)
        #expect(XPLevelSystem.didLevelUp(from: lvl5XP, to: lvl6XP))
    }

    @Test("Staying within same level is not a level up")
    func noLevelUp() {
        let lvl5XP = XPLevelSystem.xpRequired(forLevel: 5)
        #expect(XPLevelSystem.didLevelUp(from: lvl5XP, to: lvl5XP + 10) == false)
    }

    @Test("Jumping multiple levels is detected")
    func multiLevelUp() {
        let lvl2XP = XPLevelSystem.xpRequired(forLevel: 2)
        let lvl10XP = XPLevelSystem.xpRequired(forLevel: 10)
        #expect(XPLevelSystem.didLevelUp(from: lvl2XP, to: lvl10XP))
    }
}

// MARK: - Level Info Tests

@Suite("XPLevelSystem - Level Info")
struct XPLevelInfoTests {

    @Test("Level info for 0 XP returns Rookie 1")
    func levelInfoZeroXP() {
        let info = XPLevelSystem.levelInfo(forXP: 0)
        #expect(info.level == 1)
        #expect(info.league == .rookie)
        #expect(info.subRank == 1)
        #expect(info.title == "Rookie 1")
        #expect(info.currentXP == 0)
    }

    @Test("Level info for Legend tier has nil sub-rank")
    func levelInfoLegend() {
        let legendXP = XPLevelSystem.xpRequired(forLevel: 41)
        let info = XPLevelSystem.levelInfo(forXP: legendXP)
        #expect(info.league == .legend)
        #expect(info.subRank == nil)
        #expect(info.title == "Legend")
    }
}

// MARK: - XPRewardCalculator Tests

@Suite("XPRewardCalculator - Session Rewards") @MainActor
struct XPRewardCalculatorTests {

    @Test("Base session awards 10 XP")
    func baseSession() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: [],
            notes: nil, preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: nil, needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(result.totalPoints == 10)
    }

    @Test("Competition session awards 20 XP")
    func competitionSession() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .competition,
            academy: nil, instructor: nil, focusAreas: [],
            notes: nil, preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: nil, needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(result.totalPoints == 20)
        #expect(result.items.contains { $0.reason == .competitionBonus })
    }

    @Test("Full reflections add 5 XP bonus")
    func fullReflections() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: [],
            notes: "Good session", preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: "Guard passing", needsImprovement: "Escapes", keyInsights: "Hip movement"
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(result.totalPoints == 15)
        #expect(result.items.contains { $0.reason == .fullReflection })
    }

    @Test("Partial reflections do not earn bonus")
    func partialReflections() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: [],
            notes: "Good session", preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: "Guard passing", needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(result.totalPoints == 10)
        #expect(!result.items.contains { $0.reason == .fullReflection })
    }

    @Test("Whitespace-only reflections do not count")
    func whitespaceReflections() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: [],
            notes: "  ", preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: "Guard", needsImprovement: "Escapes", keyInsights: "Hips"
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(!result.items.contains { $0.reason == .fullReflection })
    }

    @Test("Both moods logged adds 3 XP bonus")
    func bothMoods() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: [],
            notes: nil, preSessionMood: 3, postSessionMood: 5,
            roundsCount: 0, whatWorkedWell: nil, needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(result.totalPoints == 13)
        #expect(result.items.contains { $0.reason == .moodTracking })
    }

    @Test("Only pre-mood does not earn mood bonus")
    func onlyPreMood() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: [],
            notes: nil, preSessionMood: 3, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: nil, needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: [])
        #expect(result.totalPoints == 10)
    }

    @Test("New focus area adds 5 XP bonus")
    func newFocusArea() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: ["Leg Locks"],
            notes: nil, preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: nil, needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: ["Guard", "Sweeps"])
        #expect(result.totalPoints == 15)
        #expect(result.items.contains { $0.reason == .newFocusArea })
    }

    @Test("No new focus area when all areas are recent")
    func noNewFocusArea() {
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .gi,
            academy: nil, instructor: nil, focusAreas: ["Guard"],
            notes: nil, preSessionMood: nil, postSessionMood: nil,
            roundsCount: 0, whatWorkedWell: nil, needsImprovement: nil, keyInsights: nil
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: ["Guard", "Sweeps"])
        #expect(result.totalPoints == 10)
    }

    @Test("All bonuses stack to maximum XP")
    func allBonusesStack() {
        // Competition (20) + reflection (5) + mood (3) + new focus (5) = 33
        let params = SessionEntryParams(
            date: Date(), duration: 3600, sessionType: .competition,
            academy: nil, instructor: nil, focusAreas: ["New Technique"],
            notes: "Great comp", preSessionMood: 5, postSessionMood: 5,
            roundsCount: 4, whatWorkedWell: "Pressure", needsImprovement: "Cardio", keyInsights: "Stay calm"
        )
        let result = XPRewardCalculator.calculate(params: params, recentFocusAreas: ["Guard"])
        #expect(result.totalPoints == 33)
        #expect(result.items.count == 5)
    }

    @Test("Check-in reward is 5 XP")
    func checkInReward() {
        let result = XPRewardCalculator.checkInReward()
        #expect(result.totalPoints == 5)
        #expect(result.items.first?.reason == .checkIn)
    }

    @Test("Streak milestone reward is 50 XP")
    func streakMilestoneReward() {
        let result = XPRewardCalculator.streakMilestoneReward()
        #expect(result.totalPoints == 50)
        #expect(result.items.first?.reason == .streakMilestone)
    }
}
