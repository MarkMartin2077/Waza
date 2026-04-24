import SwiftUI

struct CalendarMonthGridView: View {
    let days: [CalendarDayModel]
    let monthTitle: String
    let onDayTap: (CalendarDayModel) -> Void
    let onPrevMonth: () -> Void
    let onNextMonth: () -> Void
    var onTitleTap: (() -> Void)?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            weekdayRow
                .padding(.horizontal, 8)

            Divider()
                .background(Color.wazaInk300)
                .padding(.vertical, 4)

            grid
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width < -60 {
                        onNextMonth()
                    } else if value.translation.width > 60 {
                        onPrevMonth()
                    }
                    dragOffset = 0
                }
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text(monthTitle)
                .font(.wazaDisplaySmall)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("calendar.monthTitle")
                .accessibilityAddTraits(.isButton)
                .anyButton {
                    onTitleTap?()
                }

            HStack(spacing: 16) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.wazaAccent)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("calendar.prevMonth")
                    .accessibilityLabel("Previous month")
                    .anyButton {
                        onPrevMonth()
                    }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.wazaAccent)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("calendar.nextMonth")
                    .accessibilityLabel("Next month")
                    .anyButton {
                        onNextMonth()
                    }
            }
        }
    }

    // MARK: - Weekday Row

    private var weekdayRow: some View {
        HStack(spacing: 4) {
            ForEach(Array(dayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.wazaInk400)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Grid

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days) { day in
                CalendarDayCellView(day: day)
                    .overlay(CalendarDayCellView(day: day).borderOverlay)
                    .accessibilityIdentifier("calendar.day.\(day.id)")
                    .accessibilityLabel(accessibilityLabel(for: day))
                    .anyButton(.press) {
                        onDayTap(day)
                    }
            }
        }
    }

    private func accessibilityLabel(for day: CalendarDayModel) -> String {
        var parts: [String] = [Self.a11yFormatter.string(from: day.date)]
        if day.isToday { parts.append("today") }
        if day.hasSessions { parts.append(day.sessions.count == 1 ? "1 session" : "\(day.sessions.count) sessions") }
        if day.hasScheduled { parts.append(day.scheduledOccurrences.count == 1 ? "1 scheduled class" : "\(day.scheduledOccurrences.count) scheduled classes") }
        return parts.joined(separator: ", ")
    }

    private static let a11yFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - Previews

#Preview("Month Grid - With Data") {
    let calendar = Calendar.current
    let now = Date()

    let sessions: [BJJSessionModel] = BJJSessionModel.mocks
    let schedules = ClassScheduleModel.mocks
    let gymsById = Dictionary(uniqueKeysWithValues: GymLocationModel.mocks.map { ($0.gymId, $0) })

    let days = CalendarMonthBuilder.buildMonth(
        anchor: now,
        sessions: sessions,
        schedules: schedules,
        gymsById: gymsById,
        calendar: calendar,
        now: now
    )

    return CalendarMonthGridView(
        days: days,
        monthTitle: "april 2026",
        onDayTap: { _ in },
        onPrevMonth: {},
        onNextMonth: {}
    )
    .background(Color.wazaPaper)
}

#Preview("Month Grid - Empty") {
    let calendar = Calendar.current
    let now = Date()
    let days = CalendarMonthBuilder.buildMonth(
        anchor: now,
        sessions: [],
        schedules: [],
        gymsById: [:],
        calendar: calendar,
        now: now
    )
    return CalendarMonthGridView(
        days: days,
        monthTitle: "april 2026",
        onDayTap: { _ in },
        onPrevMonth: {},
        onNextMonth: {}
    )
    .background(Color.wazaPaper)
}

#Preview("Month Grid - Scheduled Only") {
    let calendar = Calendar.current
    let now = Date()
    let gymsById = Dictionary(uniqueKeysWithValues: GymLocationModel.mocks.map { ($0.gymId, $0) })
    let days = CalendarMonthBuilder.buildMonth(
        anchor: now,
        sessions: [],
        schedules: ClassScheduleModel.mocks,
        gymsById: gymsById,
        calendar: calendar,
        now: now
    )
    return CalendarMonthGridView(
        days: days,
        monthTitle: "april 2026",
        onDayTap: { _ in },
        onPrevMonth: {},
        onNextMonth: {}
    )
    .background(Color.wazaPaper)
}
