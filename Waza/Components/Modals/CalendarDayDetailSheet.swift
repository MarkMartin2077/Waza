import SwiftUI

struct CalendarDayDetailSheet: View {
    let day: CalendarDayModel
    let callbacks: CalendarDayDetailCallbacks

    @Environment(\.dismiss) private var dismiss

    // Each CTA sets the presenter's pendingAction (via the callback) and then
    // dismisses the sheet. The sheet's onDismiss fires after the animation
    // completes, at which point the presenter routes to the queued screen.
    private func onSessionTap(_ session: BJJSessionModel) {
        callbacks.onSessionTap(session)
        dismiss()
    }
    private func onOccurrenceTap(_ occurrence: ScheduledClassOccurrence) {
        callbacks.onOccurrenceTap(occurrence)
        dismiss()
    }
    private func onAddSchedule() {
        callbacks.onAddSchedule()
        dismiss()
    }
    private func onLogSession() {
        callbacks.onLogSession()
        dismiss()
    }
    private func onViewAllSessions() {
        callbacks.onViewAllSessions()
        dismiss()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headlineSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                Divider()
                    .background(Color.wazaInk300)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                bodySection
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                Color.clear.frame(height: 32)
            }
        }
        .background(Color.wazaPaper)
    }

    // MARK: - Headline

    private var headlineSection: some View {
        Text(headlineText)
            .font(.wazaDisplaySmall)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headlineText: String {
        Self.headlineFormatter.string(from: day.date)
    }

    private static let headlineFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    // MARK: - Body

    @ViewBuilder
    private var bodySection: some View {
        if day.isToday {
            todayBody
        } else if day.isFuture {
            futureBody
        } else {
            pastBody
        }
    }

    // MARK: - Past

    @ViewBuilder
    private var pastBody: some View {
        if day.hasSessions {
            pastWithSessionsBody
        } else {
            pastEmptyBody
        }
    }

    private var pastWithSessionsBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            let sessionCount = day.sessions.count
            let totalSeconds = Int(day.sessions.reduce(0) { $0 + $1.duration })
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let hoursString = hours == 0 ? "\(minutes)m"
                : minutes == 0 ? "\(hours)h"
                : "\(hours)h \(minutes)m"
            let countWord = sessionCount == 1 ? "One session" : "\(sessionCount) sessions"

            Text("\(countWord). \(hoursString) on the mat.")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk600)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                ForEach(day.sessions) { session in
                    sessionRow(session)
                        .anyButton {
                            onSessionTap(session)
                        }
                }
            }

            logAnotherButton

            Text("View all sessions")
                .font(.wazaLabel)
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(Color.wazaInk500)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                .accessibilityIdentifier("dayDetail.viewAllSessions")
                .anyButton {
                    onViewAllSessions()
                }
        }
    }

    private func sessionRow(_ session: BJJSessionModel) -> some View {
        HStack(spacing: 12) {
            Text(session.sessionType.kanji)
                .font(.system(size: 18))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.sessionType.displayName)
                    .font(.wazaBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.wazaInk900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let academy = session.academy {
                    Text(academy)
                        .font(.wazaLabel)
                        .foregroundStyle(Color.wazaInk500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Text(session.durationFormatted)
                .font(.wazaLabel)
                .foregroundStyle(Color.wazaInk500)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.wazaPaperHi, in: RoundedRectangle(cornerRadius: .wazaCornerSmall))
    }

    private var logAnotherButton: some View {
        Text("Log another")
            .font(.wazaBody)
            .fontWeight(.medium)
            .foregroundStyle(Color.wazaAccent)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .strokeBorder(Color.wazaAccent, lineWidth: 1)
            )
            .accessibilityIdentifier("dayDetail.logAnother")
            .anyButton(.press) {
                onLogSession()
            }
    }

    @ViewBuilder
    private var pastEmptyBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rest day.")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk900)
                .frame(maxWidth: .infinity, alignment: .leading)

            let isWithin14Days = day.date >= Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()

            if isWithin14Days {
                Text("Recovery is part of the art.")
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaInk500)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Log a session here")
                    .font(.wazaBody)
                    .foregroundStyle(Color.wazaAccent)
                    .accessibilityIdentifier("dayDetail.logSessionHere")
                    .anyButton {
                        onLogSession()
                    }
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Future

    @ViewBuilder
    private var futureBody: some View {
        if day.hasScheduled {
            futureWithScheduleBody
        } else {
            futureEmptyBody
        }
    }

    private var futureWithScheduleBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(day.scheduledOccurrences) { occurrence in
                occurrenceRow(occurrence)
                    .anyButton {
                        onOccurrenceTap(occurrence)
                    }
            }
        }
    }

    private func occurrenceRow(_ occurrence: ScheduledClassOccurrence) -> some View {
        HStack(spacing: 12) {
            Text(occurrence.schedule.sessionType.kanji)
                .font(.system(size: 18))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(occurrence.gym.name)
                    .font(.wazaBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.wazaInk900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(timeString(from: occurrence.occursAt) + " · " + occurrence.schedule.sessionType.displayName)
                    .font(.wazaLabel)
                    .foregroundStyle(Color.wazaInk500)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.wazaInk400)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.wazaPaperHi, in: RoundedRectangle(cornerRadius: .wazaCornerSmall))
    }

    private func timeString(from date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }

    private var futureEmptyBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nothing scheduled.")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Add a recurring class to make this day regular.")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk500)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Add to schedule")
                .font(.wazaBody)
                .fontWeight(.medium)
                .foregroundStyle(Color.wazaAccent)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .strokeBorder(Color.wazaAccent, lineWidth: 1)
                )
                .accessibilityIdentifier("dayDetail.addToSchedule")
                .anyButton(.press) {
                    onAddSchedule()
                }
                .padding(.top, 8)
        }
    }

    // MARK: - Today

    private var todayBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            if day.hasSessions {
                pastWithSessionsBody

                Divider()
                    .background(Color.wazaInk300)
                    .padding(.vertical, 16)
            }

            if day.hasScheduled {
                todayUpcomingSection
            } else if !day.hasSessions {
                pastEmptyBody
            }
        }
    }

    private var todayUpcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UPCOMING TODAY")
                .wazaLabelStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            let now = Date()
            ForEach(day.scheduledOccurrences) { occurrence in
                let windowStart = occurrence.occursAt.addingTimeInterval(-30 * 60)
                let windowEnd = occurrence.occursAt.addingTimeInterval(30 * 60)
                let isCheckInWindow = now >= windowStart && now <= windowEnd

                if isCheckInWindow {
                    checkInCTAButton(occurrence)
                } else {
                    occurrenceRow(occurrence)
                        .anyButton {
                            onOccurrenceTap(occurrence)
                        }
                }
            }
        }
    }

    private func checkInCTAButton(_ occurrence: ScheduledClassOccurrence) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(occurrence.gym.name)
                    .font(.wazaBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.wazaPaperHi)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Class in progress — check in now")
                    .font(.wazaLabel)
                    .foregroundStyle(Color.wazaPaperHi.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Image(systemName: "checkmark.circle")
                .font(.title3)
                .foregroundStyle(Color.wazaPaperHi)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(Color.wazaAccent)
        )
        .anyButton(.press) {
            onOccurrenceTap(occurrence)
        }
    }
}

// MARK: - Previews

#Preview("Past with sessions") {
    CalendarDayDetailSheet(
        day: CalendarDayModel(
            id: "2026-04-20",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
            sessions: Array(BJJSessionModel.mocks.prefix(2)),
            scheduledOccurrences: [],
            isToday: false,
            isInDisplayedMonth: true,
            isFuture: false
        ),
        callbacks: CalendarDayDetailCallbacks(
            onSessionTap: { _ in },
            onOccurrenceTap: { _ in },
            onAddSchedule: {},
            onLogSession: {},
            onViewAllSessions: {},
            onDismiss: {}
        )
    )
}

#Preview("Past empty (within 14 days)") {
    CalendarDayDetailSheet(
        day: CalendarDayModel(
            id: "2026-04-22",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            sessions: [],
            scheduledOccurrences: [],
            isToday: false,
            isInDisplayedMonth: true,
            isFuture: false
        ),
        callbacks: CalendarDayDetailCallbacks(
            onSessionTap: { _ in },
            onOccurrenceTap: { _ in },
            onAddSchedule: {},
            onLogSession: {},
            onViewAllSessions: {},
            onDismiss: {}
        )
    )
}

#Preview("Future with schedule") {
    CalendarDayDetailSheet(
        day: CalendarDayModel(
            id: "2026-04-28",
            date: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
            sessions: [],
            scheduledOccurrences: [
                ScheduledClassOccurrence(
                    id: "mock-occ-1",
                    schedule: ClassScheduleModel.mock,
                    gym: GymLocationModel.mock,
                    occursAt: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date()
                )
            ],
            isToday: false,
            isInDisplayedMonth: true,
            isFuture: true
        ),
        callbacks: CalendarDayDetailCallbacks(
            onSessionTap: { _ in },
            onOccurrenceTap: { _ in },
            onAddSchedule: {},
            onLogSession: {},
            onViewAllSessions: {},
            onDismiss: {}
        )
    )
}

#Preview("Future empty") {
    CalendarDayDetailSheet(
        day: CalendarDayModel(
            id: "2026-04-30",
            date: Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date(),
            sessions: [],
            scheduledOccurrences: [],
            isToday: false,
            isInDisplayedMonth: true,
            isFuture: true
        ),
        callbacks: CalendarDayDetailCallbacks(
            onSessionTap: { _ in },
            onOccurrenceTap: { _ in },
            onAddSchedule: {},
            onLogSession: {},
            onViewAllSessions: {},
            onDismiss: {}
        )
    )
}

#Preview("Today - mixed") {
    CalendarDayDetailSheet(
        day: CalendarDayModel(
            id: "2026-04-24",
            date: Date(),
            sessions: [BJJSessionModel.mock],
            scheduledOccurrences: [
                ScheduledClassOccurrence(
                    id: "mock-occ-today",
                    schedule: ClassScheduleModel.mock,
                    gym: GymLocationModel.mock,
                    occursAt: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
                )
            ],
            isToday: true,
            isInDisplayedMonth: true,
            isFuture: false
        ),
        callbacks: CalendarDayDetailCallbacks(
            onSessionTap: { _ in },
            onOccurrenceTap: { _ in },
            onAddSchedule: {},
            onLogSession: {},
            onViewAllSessions: {},
            onDismiss: {}
        )
    )
}
