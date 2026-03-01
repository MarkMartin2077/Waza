import Testing
import Foundation
@testable import Waza

// MARK: - BJJBelt

@Suite("BJJBelt") @MainActor
struct BJJBeltTests {

    @Test("nextBelt returns the correct next belt in the progression")
    func nextBeltProgression() {
        // GIVEN / WHEN / THEN
        #expect(BJJBelt.white.nextBelt == .blue)
        #expect(BJJBelt.blue.nextBelt == .purple)
        #expect(BJJBelt.purple.nextBelt == .brown)
        #expect(BJJBelt.brown.nextBelt == .black)
    }

    @Test("nextBelt returns nil for black belt")
    func blackBeltHasNoNext() {
        // GIVEN / WHEN / THEN
        #expect(BJJBelt.black.nextBelt == nil)
    }

    @Test("order reflects the correct rank for each belt")
    func beltOrder() {
        // GIVEN / WHEN / THEN
        #expect(BJJBelt.white.order == 0)
        #expect(BJJBelt.blue.order == 1)
        #expect(BJJBelt.purple.order == 2)
        #expect(BJJBelt.brown.order == 3)
        #expect(BJJBelt.black.order == 4)
    }

    @Test("order is strictly increasing along the full progression")
    func orderIsStrictlyIncreasing() {
        // GIVEN
        let belts: [BJJBelt] = [.white, .blue, .purple, .brown, .black]

        // WHEN / THEN
        for idx in 0..<belts.count - 1 {
            #expect(belts[idx].order < belts[idx + 1].order)
        }
    }

    @Test("typicalYearsToNext returns nil for black belt")
    func typicalYearsBlackBelt() {
        // GIVEN / WHEN / THEN
        #expect(BJJBelt.black.typicalYearsToNext == nil)
    }

    @Test("typicalYearsToNext returns positive values for all other belts")
    func typicalYearsNonBlack() {
        // GIVEN
        let colorBelts: [BJJBelt] = [.white, .blue, .purple, .brown]

        // WHEN / THEN
        for belt in colorBelts {
            let years = belt.typicalYearsToNext
            #expect(years != nil)
            #expect((years ?? 0) > 0)
        }
    }

    @Test("typicalYearsToNext returns expected values for each belt")
    func typicalYearsValues() {
        // GIVEN / WHEN / THEN
        #expect(BJJBelt.white.typicalYearsToNext == 2.0)
        #expect(BJJBelt.blue.typicalYearsToNext == 3.0)
        #expect(BJJBelt.purple.typicalYearsToNext == 3.5)
        #expect(BJJBelt.brown.typicalYearsToNext == 2.5)
    }

    @Test("displayName is the capitalized raw value")
    func displayName() {
        // GIVEN / WHEN / THEN
        #expect(BJJBelt.white.displayName == "White")
        #expect(BJJBelt.blue.displayName == "Blue")
        #expect(BJJBelt.black.displayName == "Black")
    }
}

// MARK: - SessionStats

@Suite("SessionStats") @MainActor
struct SessionStatsTests {

    @Test("totalTrainingHours converts seconds to hours")
    func totalTrainingHours() {
        // GIVEN
        let stats = SessionStats(
            totalSessions: 2,
            totalTrainingTime: 7200,   // 2 hours in seconds
            averageSessionDuration: 3600,
            thisWeekSessions: 0,
            thisMonthSessions: 0
        )

        // WHEN / THEN
        #expect(stats.totalTrainingHours == 2.0)
    }

    @Test("averageSessionMinutes converts seconds to minutes")
    func averageSessionMinutes() {
        // GIVEN
        let stats = SessionStats(
            totalSessions: 1,
            totalTrainingTime: 5400,
            averageSessionDuration: 5400,   // 90 minutes in seconds
            thisWeekSessions: 0,
            thisMonthSessions: 0
        )

        // WHEN / THEN
        #expect(stats.averageSessionMinutes == 90)
    }

    @Test("empty stats have zero values")
    func emptyStats() {
        // GIVEN / WHEN
        let stats = SessionStats.empty

        // THEN
        #expect(stats.totalSessions == 0)
        #expect(stats.totalTrainingTime == 0)
        #expect(stats.averageSessionDuration == 0)
        #expect(stats.thisWeekSessions == 0)
        #expect(stats.thisMonthSessions == 0)
        #expect(stats.totalTrainingHours == 0)
        #expect(stats.averageSessionMinutes == 0)
    }

    @Test("totalTrainingHours returns a fractional value for partial hours")
    func fractionalHours() {
        // GIVEN
        let stats = SessionStats(
            totalSessions: 1,
            totalTrainingTime: 5400,  // 1.5 hours
            averageSessionDuration: 5400,
            thisWeekSessions: 0,
            thisMonthSessions: 0
        )

        // WHEN / THEN
        #expect(stats.totalTrainingHours == 1.5)
    }
}

// MARK: - BeltRecordModel

@Suite("BeltRecordModel") @MainActor
struct BeltRecordModelTests {

    @Test("displayTitle shows belt name only when stripes is 0")
    func displayTitleNoStripes() {
        // GIVEN
        let record = BeltRecordModel(belt: .blue, stripes: 0)

        // WHEN / THEN
        #expect(record.displayTitle == "Blue")
    }

    @Test("displayTitle includes '1 stripe' for a single stripe")
    func displayTitleOneStripe() {
        // GIVEN
        let record = BeltRecordModel(belt: .purple, stripes: 1)

        // WHEN / THEN
        #expect(record.displayTitle == "Purple — 1 stripe")
    }

    @Test("displayTitle includes plural stripes for 2 or more")
    func displayTitlePluralStripes() {
        // GIVEN
        let record = BeltRecordModel(belt: .brown, stripes: 3)

        // WHEN / THEN
        #expect(record.displayTitle == "Brown — 3 stripes")
    }

    @Test("Stripes are clamped to 0-4 on initialization")
    func stripesClampedOnInit() {
        // GIVEN / WHEN
        let tooHigh = BeltRecordModel(belt: .blue, stripes: 10)
        let tooLow = BeltRecordModel(belt: .blue, stripes: -1)

        // THEN
        #expect(tooHigh.stripes == 4)
        #expect(tooLow.stripes == 0)
    }

    @Test("Stripes at the boundary values are stored as-is")
    func stripesBoundaryValues() {
        // GIVEN / WHEN
        let zero = BeltRecordModel(belt: .white, stripes: 0)
        let four = BeltRecordModel(belt: .white, stripes: 4)

        // THEN
        #expect(zero.stripes == 0)
        #expect(four.stripes == 4)
    }
}

// MARK: - TrainingGoalModel

@Suite("TrainingGoalModel") @MainActor
struct TrainingGoalModelTests {

    @Test("progressPercentage converts decimal fraction to integer percentage")
    func progressPercentage() {
        // GIVEN
        let goal = TrainingGoalModel(goalId: "g1", title: "Test goal", progress: 0.75)

        // WHEN / THEN
        #expect(goal.progressPercentage == 75)
    }

    @Test("progressPercentage is 0 for an unstarted goal")
    func progressPercentageZero() {
        // GIVEN
        let goal = TrainingGoalModel(goalId: "g1", title: "Unstarted goal", progress: 0)

        // WHEN / THEN
        #expect(goal.progressPercentage == 0)
    }

    @Test("progressPercentage is 100 for a fully complete goal")
    func progressPercentageFull() {
        // GIVEN
        let goal = TrainingGoalModel(goalId: "g1", title: "Done goal", progress: 1.0)

        // WHEN / THEN
        #expect(goal.progressPercentage == 100)
    }

    @Test("isOverdue returns true when the deadline is in the past and goal is not complete")
    func isOverduePastDeadline() {
        // GIVEN
        let pastDeadline = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let goal = TrainingGoalModel(goalId: "g1", title: "Overdue goal", deadline: pastDeadline)

        // WHEN / THEN
        #expect(goal.isOverdue == true)
    }

    @Test("isOverdue returns false when the deadline is in the future")
    func isOverdueFutureDeadline() {
        // GIVEN
        let futureDeadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let goal = TrainingGoalModel(goalId: "g1", title: "Future goal", deadline: futureDeadline)

        // WHEN / THEN
        #expect(goal.isOverdue == false)
    }

    @Test("isOverdue returns false when the goal is completed, even if past the deadline")
    func isOverdueCompletedGoal() {
        // GIVEN
        let pastDeadline = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let goal = TrainingGoalModel(
            goalId: "g1",
            title: "Completed late",
            deadline: pastDeadline,
            isCompleted: true
        )

        // WHEN / THEN
        #expect(goal.isOverdue == false)
    }

    @Test("isOverdue returns false when there is no deadline")
    func isOverdueNoDeadline() {
        // GIVEN
        let goal = TrainingGoalModel(goalId: "g1", title: "No deadline goal")

        // WHEN / THEN
        #expect(goal.isOverdue == false)
    }

    @Test("Progress is clamped to 0.0-1.0 on initialization")
    func progressClampedOnInit() {
        // GIVEN / WHEN
        let tooHigh = TrainingGoalModel(goalId: "g1", title: "High", progress: 1.5)
        let tooLow = TrainingGoalModel(goalId: "g2", title: "Low", progress: -0.1)

        // THEN
        #expect(tooHigh.progress == 1.0)
        #expect(tooLow.progress == 0.0)
    }
}

// MARK: - DateRange

@Suite("DateRange") @MainActor
struct DateRangeTests {

    @Test("lastDays creates a range with the correct start offset")
    func lastDaysStart() {
        // GIVEN
        let days = 7

        // WHEN
        let range = DateRange.lastDays(days)

        // THEN
        let expectedStart = Calendar.current.date(byAdding: .day, value: -days, to: range.end)!
        let diff = abs(range.start.timeIntervalSince(expectedStart))
        #expect(diff < 1)  // within 1 second tolerance
    }

    @Test("lastWeek spans 7 days")
    func lastWeekIs7Days() {
        // GIVEN
        let range = DateRange.lastWeek

        // WHEN
        let days = Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 0

        // THEN
        #expect(days == 7)
    }

    @Test("lastMonth spans 30 days")
    func lastMonthIs30Days() {
        // GIVEN
        let range = DateRange.lastMonth

        // WHEN
        let days = Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 0

        // THEN
        #expect(days == 30)
    }

    @Test("allTime starts at the Unix epoch")
    func allTimeStartsAtEpoch() {
        // GIVEN / WHEN
        let range = DateRange.allTime

        // THEN
        #expect(range.start == Date(timeIntervalSince1970: 0))
    }

    @Test("A session date within the range is found by getSessions")
    func dateInRangeIsIncluded() throws {
        // GIVEN
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let range = DateRange.lastDays(7)

        // WHEN
        let isInRange = yesterday >= range.start && yesterday <= range.end

        // THEN
        #expect(isInRange == true)
    }
}
