import SwiftUI

struct CalendarDayCellView: View {
    let day: CalendarDayModel

    var body: some View {
        ZStack {
            cellBackground
            cellContent
            if day.isToday {
                todayRing
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Background

    private var cellBackground: some View {
        Group {
            if day.hasSessions {
                Color.wazaAccent
            } else {
                Color.wazaPaperHi
            }
        }
    }

    // MARK: - Border

    private var cellBorderColor: Color {
        // Session cells get a dark border as a second signal alongside the red fill —
        // ensures the "trained" state is distinguishable without color perception.
        if day.hasSessions { return Color.wazaInk900 }
        if !day.isInDisplayedMonth { return .clear }
        if day.isFuture && day.hasScheduled { return Color.wazaInk500 }
        return Color.wazaInk300
    }

    private var cellBorderWidth: CGFloat {
        if day.hasSessions { return 1 }
        if day.isFuture && day.hasScheduled { return 1 }
        if !day.isInDisplayedMonth { return 0 }
        return 0.5
    }

    private var isDashed: Bool {
        day.isFuture && day.hasScheduled && !day.hasSessions
    }

    // MARK: - Content

    @ViewBuilder
    private var cellContent: some View {
        if day.hasSessions {
            // Past day with session(s): show kanji + optional count.
            VStack(spacing: 0) {
                Text(day.primaryKanji ?? "技")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.wazaPaperHi)
                if day.sessions.count > 1 {
                    Text("×\(day.sessions.count)")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.wazaPaperHi.opacity(0.7))
                }
            }
        } else if day.isFuture && day.hasScheduled {
            // Future day, scheduled class: show 時 kanji with date numeral.
            ZStack(alignment: .topLeading) {
                Text("時")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.wazaInk600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                dateNumeral(color: Color.wazaInk500)
            }
        } else {
            // Empty day: date numeral only.
            dateNumeral(color: day.isToday
                        ? Color.wazaInk900
                        : (day.isInDisplayedMonth ? Color.wazaInk400 : Color.wazaInk300))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func dateNumeral(color: Color) -> some View {
        Text(dayNumber)
            .font(day.isToday ? .system(size: 9, weight: .bold) : .wazaLabel)
            .foregroundStyle(color)
            .padding(3)
    }

    private var dayNumber: String {
        let cal = Calendar.current
        return "\(cal.component(.day, from: day.date))"
    }

    // MARK: - Today Ring

    private var todayRing: some View {
        RoundedRectangle(cornerRadius: 4)
            .strokeBorder(Color.wazaInk900, lineWidth: 1.5)
    }

    // MARK: - Cell border overlay (non-today)

    var borderOverlay: some View {
        Group {
            if isDashed {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    .foregroundStyle(cellBorderColor)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(cellBorderColor, lineWidth: cellBorderWidth)
            }
        }
    }
}

// CalendarDayCellView uses a separate overlay because SwiftUI clips overlays inside ZStack
// when using .clipShape; callers must apply borderOverlay externally in the grid.

// MARK: - Previews

#Preview("Past session") {
    CalendarDayCellView(day: CalendarDayModel(
        id: "2026-04-01",
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        sessions: [BJJSessionModel.mock],
        scheduledOccurrences: [],
        isToday: false,
        isInDisplayedMonth: true,
        isFuture: false
    ))
    .frame(width: 44, height: 44)
    .padding()
}

#Preview("Past multiple sessions") {
    CalendarDayCellView(day: CalendarDayModel(
        id: "2026-04-02",
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
        sessions: Array(BJJSessionModel.mocks.prefix(3)),
        scheduledOccurrences: [],
        isToday: false,
        isInDisplayedMonth: true,
        isFuture: false
    ))
    .frame(width: 44, height: 44)
    .padding()
}

#Preview("Today empty") {
    CalendarDayCellView(day: CalendarDayModel(
        id: "2026-04-24",
        date: Date(),
        sessions: [],
        scheduledOccurrences: [],
        isToday: true,
        isInDisplayedMonth: true,
        isFuture: false
    ))
    .frame(width: 44, height: 44)
    .padding()
}

#Preview("Future scheduled") {
    CalendarDayCellView(day: CalendarDayModel(
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
    ))
    .frame(width: 44, height: 44)
    .padding()
}

#Preview("Empty past") {
    CalendarDayCellView(day: CalendarDayModel(
        id: "2026-04-10",
        date: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
        sessions: [],
        scheduledOccurrences: [],
        isToday: false,
        isInDisplayedMonth: true,
        isFuture: false
    ))
    .frame(width: 44, height: 44)
    .padding()
}

#Preview("Out of month") {
    CalendarDayCellView(day: CalendarDayModel(
        id: "2026-03-31",
        date: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
        sessions: [],
        scheduledOccurrences: [],
        isToday: false,
        isInDisplayedMonth: false,
        isFuture: false
    ))
    .frame(width: 44, height: 44)
    .padding()
}
