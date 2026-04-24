import Foundation

/// Pure, stateless builder — no UIKit, no SwiftUI, no side effects.
/// Inject `calendar` and `now` for full testability.
struct CalendarMonthBuilder {

    // MARK: - Public API

    static func buildMonth(
        anchor: Date,
        sessions: [BJJSessionModel],
        schedules: [ClassScheduleModel],
        gymsById: [String: GymLocationModel],
        calendar: Calendar = .current,
        now: Date = Date()
    ) -> [CalendarDayModel] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: anchor),
            let gridStart = gridStartDate(for: monthInterval.start, calendar: calendar),
            let gridEnd = calendar.date(byAdding: .day, value: 42, to: gridStart)
        else { return [] }

        let displayedMonth = calendar.component(.month, from: anchor)
        let displayedYear = calendar.component(.year, from: anchor)

        // Bucket sessions by day key once — O(n) pass.
        let formatter = dayKeyFormatter(timeZone: calendar.timeZone)
        var sessionBucket: [String: [BJJSessionModel]] = [:]
        for session in sessions {
            let key = formatter.string(from: session.date)
            sessionBucket[key, default: []].append(session)
        }

        // Expand schedules into occurrences within the 42-day grid.
        let allOccurrences = occurrences(
            of: schedules,
            gymsById: gymsById,
            in: gridStart..<gridEnd,
            calendar: calendar
        )
        // Drop past occurrences where no session exists on that day (they aren't actionable).
        let futureOccurrences = allOccurrences.filter { $0.occursAt >= now }

        var occurrenceBucket: [String: [ScheduledClassOccurrence]] = [:]
        for occurrence in futureOccurrences {
            let key = formatter.string(from: occurrence.occursAt)
            occurrenceBucket[key, default: []].append(occurrence)
        }

        // Build 42 cells.
        return (0..<42).compactMap { offset -> CalendarDayModel? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: gridStart) else { return nil }
            let startOfDay = calendar.startOfDay(for: day)
            let key = formatter.string(from: startOfDay)

            let dayMonth = calendar.component(.month, from: startOfDay)
            let dayYear = calendar.component(.year, from: startOfDay)
            let isInDisplayedMonth = dayMonth == displayedMonth && dayYear == displayedYear
            // Use injected `now` + calendar so tests aren't flaky across timezones / wall clock.
            let isToday = calendar.isDate(startOfDay, inSameDayAs: now)
            let isFuture = startOfDay > calendar.startOfDay(for: now)

            return CalendarDayModel(
                id: key,
                date: startOfDay,
                sessions: sessionBucket[key] ?? [],
                scheduledOccurrences: occurrenceBucket[key] ?? [],
                isToday: isToday,
                isInDisplayedMonth: isInDisplayedMonth,
                isFuture: isFuture
            )
        }
    }

    // MARK: - Occurrence Expansion

    static func occurrences(
        of schedules: [ClassScheduleModel],
        gymsById: [String: GymLocationModel],
        in range: Range<Date>,
        calendar: Calendar
    ) -> [ScheduledClassOccurrence] {
        var result: [ScheduledClassOccurrence] = []
        let formatter = occurrenceIdFormatter(timeZone: calendar.timeZone)

        for schedule in schedules where schedule.isActive {
            guard let gym = gymsById[schedule.gymId] else { continue }

            var cursor = range.lowerBound
            while cursor < range.upperBound {
                let weekday = calendar.component(.weekday, from: cursor)
                if weekday == schedule.dayOfWeek {
                    let occursAt = cursor.addingTimeInterval(
                        TimeInterval(schedule.startHour * 3600 + schedule.startMinute * 60)
                    )
                    let occurrenceIdSuffix = formatter.string(from: occursAt)
                    let occurrence = ScheduledClassOccurrence(
                        id: "\(schedule.scheduleId)-\(occurrenceIdSuffix)",
                        schedule: schedule,
                        gym: gym,
                        occursAt: occursAt
                    )
                    result.append(occurrence)
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = next
            }
        }

        return result
    }

    // MARK: - Private Helpers

    private static func gridStartDate(for firstDayOfMonth: Date, calendar: Calendar) -> Date? {
        // Find the Sunday (or Monday based on locale) that opens the week containing the 1st.
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: firstDayOfMonth) else { return nil }
        return weekInterval.start
    }

    private static func dayKeyFormatter(timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        return formatter
    }

    private static func occurrenceIdFormatter(timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        return formatter
    }
}
