import Testing
import Foundation
@testable import Waza

// MARK: - Test Helpers

private func utcCalendar() -> Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    return cal
}

private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar = utcCalendar()) -> Date {
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = 0
    comps.minute = 0
    comps.second = 0
    return calendar.date(from: comps)!
}

private func mockSchedule(
    id: String = UUID().uuidString,
    gymId: String = "gym-1",
    dayOfWeek: Int,
    startHour: Int = 19,
    startMinute: Int = 0,
    isActive: Bool = true
) -> ClassScheduleModel {
    ClassScheduleModel(
        scheduleId: id,
        gymId: gymId,
        name: "Test Class",
        dayOfWeek: dayOfWeek,
        startHour: startHour,
        startMinute: startMinute,
        durationMinutes: 60,
        isActive: isActive
    )
}

private func mockGym(id: String = "gym-1") -> GymLocationModel {
    GymLocationModel(gymId: id, name: "Test Gym")
}

// MARK: - Tests

@Suite("CalendarMonthBuilder")
struct CalendarMonthBuilderTests {

    let calendar = utcCalendar()

    // 1. Always returns exactly 42 cells
    @Test func test_buildMonth_returnsExactly42Cells() {
        let anchor = date(2026, 4, 1)
        let result = CalendarMonthBuilder.buildMonth(
            anchor: anchor,
            sessions: [],
            schedules: [],
            gymsById: [:],
            calendar: calendar,
            now: date(2026, 4, 1)
        )
        #expect(result.count == 42)
    }

    // 2. isInDisplayedMonth correct for leading and trailing padding days
    @Test func test_buildMonth_marksIsInDisplayedMonth_correctlyForLeadingAndTrailingDays() {
        let anchor = date(2026, 4, 15)   // April 2026
        let result = CalendarMonthBuilder.buildMonth(
            anchor: anchor,
            sessions: [],
            schedules: [],
            gymsById: [:],
            calendar: calendar,
            now: date(2026, 4, 1)
        )

        let inMonth = result.filter(\.isInDisplayedMonth)
        let outOfMonth = result.filter { !$0.isInDisplayedMonth }

        // April has 30 days, so exactly 30 cells must be in-month.
        #expect(inMonth.count == 30)
        // Remaining 12 cells are padding (leading March days + trailing May days).
        #expect(outOfMonth.count == 12)
    }

    // 3. isToday set on exactly one cell matching today's date
    @Test func test_buildMonth_marksIsToday_onlyForTodayCell() {
        let today = date(2026, 4, 24)
        let result = CalendarMonthBuilder.buildMonth(
            anchor: date(2026, 4, 1),
            sessions: [],
            schedules: [],
            gymsById: [:],
            calendar: calendar,
            now: today
        )

        let todayCells = result.filter(\.isToday)
        #expect(todayCells.count == 1)
        #expect(todayCells.first?.id == "2026-04-24")
    }

    // 4. occurrences expands a weekly schedule to every matching weekday in the range
    @Test func test_occurrences_expandsWeeklyScheduleToEveryMatchingWeekday() {
        // dayOfWeek 2 = Monday (Calendar.weekday convention)
        let schedule = mockSchedule(dayOfWeek: 2)
        let gym = mockGym()
        let start = date(2026, 4, 1)          // Wednesday
        let end = date(2026, 4, 29)           // 28 days later

        let result = CalendarMonthBuilder.occurrences(
            of: [schedule],
            gymsById: ["gym-1": gym],
            in: start..<end,
            calendar: calendar
        )

        // Mondays in April 2026: 6, 13, 20, 27 → 4 occurrences
        #expect(result.count == 4)
        let weekdays = result.map { calendar.component(.weekday, from: $0.occursAt) }
        #expect(weekdays.allSatisfy { $0 == 2 })
    }

    // 5. Inactive schedules are skipped
    @Test func test_occurrences_skipsInactiveSchedules() {
        let active = mockSchedule(id: "active", dayOfWeek: 2, isActive: true)
        let inactive = mockSchedule(id: "inactive", dayOfWeek: 4, isActive: false)
        let gym = mockGym()
        let start = date(2026, 4, 1)
        let end = date(2026, 5, 1)

        let result = CalendarMonthBuilder.occurrences(
            of: [active, inactive],
            gymsById: ["gym-1": gym],
            in: start..<end,
            calendar: calendar
        )

        let scheduleIds = result.map { $0.schedule.scheduleId }
        #expect(scheduleIds.allSatisfy { $0 == "active" })
    }

    // 6. occurrences skips schedules whose gym is missing from gymsById
    @Test func test_occurrences_skipsOccurrencesWithMissingGym() {
        let schedule = mockSchedule(gymId: "gym-missing", dayOfWeek: 2)
        let start = date(2026, 4, 1)
        let end = date(2026, 5, 1)

        let result = CalendarMonthBuilder.occurrences(
            of: [schedule],
            gymsById: [:],          // empty — gym not registered
            in: start..<end,
            calendar: calendar
        )

        #expect(result.isEmpty)
    }

    // 7. Past occurrences are dropped when no session exists on that day
    @Test func test_buildMonth_dropsPastOccurrencesWhenNoSessionOnThatDay() {
        // "now" is April 24; a Monday schedule on April 20 (past, no session) should not appear.
        let now = date(2026, 4, 24)
        let schedule = mockSchedule(dayOfWeek: 2) // Mondays: Apr 6, 13, 20, 27
        let gym = mockGym()

        let result = CalendarMonthBuilder.buildMonth(
            anchor: date(2026, 4, 1),
            sessions: [],
            schedules: [schedule],
            gymsById: ["gym-1": gym],
            calendar: calendar,
            now: now
        )

        // April 6, 13, 20 are past Mondays — they should have no occurrences (no session either).
        let pastMondayIds = ["2026-04-06", "2026-04-13", "2026-04-20"]
        for id in pastMondayIds {
            let cell = result.first(where: { $0.id == id })
            #expect(cell?.scheduledOccurrences.isEmpty == true)
        }

        // April 27 is a future Monday — should have one occurrence.
        let futureMonday = result.first(where: { $0.id == "2026-04-27" })
        #expect(futureMonday?.scheduledOccurrences.count == 1)
    }

    // 8. DST-transition month still produces 42 cells with correct day keys
    @Test func test_buildMonth_handlesDSTTransitionMonth() {
        // US spring-forward 2026 is Sunday March 8. Using local TZ that observes DST.
        var localCal = Calendar(identifier: .gregorian)
        localCal.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        let anchor = date(2026, 3, 15, calendar: localCal)
        let result = CalendarMonthBuilder.buildMonth(
            anchor: anchor,
            sessions: [],
            schedules: [],
            gymsById: [:],
            calendar: localCal,
            now: date(2026, 3, 1, calendar: localCal)
        )

        // Even across DST, we must still emit exactly 42 unique day keys — no duplicates, no skips.
        let ids = result.map(\.id)
        #expect(ids.count == 42)
        #expect(Set(ids).count == 42)
    }

    // 9. Multiple sessions on the same day are bucketed together
    @Test func test_buildMonth_bucketsMultipleSessionsOnSameDay() {
        let targetDate = date(2026, 4, 20)
        let session1 = BJJSessionModel(sessionId: "s1", date: targetDate, sessionType: .gi)
        let session2 = BJJSessionModel(sessionId: "s2", date: targetDate, sessionType: .noGi)

        let result = CalendarMonthBuilder.buildMonth(
            anchor: date(2026, 4, 1),
            sessions: [session1, session2],
            schedules: [],
            gymsById: [:],
            calendar: calendar,
            now: date(2026, 4, 24)
        )

        let cell = result.first(where: { $0.id == "2026-04-20" })
        #expect(cell?.sessions.count == 2)
    }
}
