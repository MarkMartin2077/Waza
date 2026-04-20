import SwiftUI

struct AttendanceCalendarView: View {
    let attendance: [ClassAttendanceModel]

    private let cellSize: CGFloat = 16
    private let cellSpacing: CGFloat = 4
    private let daySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    // Count of check-ins per day, keyed by "yyyy-MM-dd"
    private var countsByDate: [String: Int] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        var counts: [String: Int] = [:]
        for record in attendance {
            let key = fmt.string(from: record.checkInDate)
            counts[key, default: 0] += 1
        }
        return counts
    }

    // 12 columns (weeks, oldest→newest) × 7 rows (Sun–Sat)
    private var calendarWeeks: [[Date?]] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today) // 1=Sun…7=Sat
        guard
            let thisSunday = cal.date(byAdding: .day, value: -(weekday - 1), to: today),
            let firstSunday = cal.date(byAdding: .weekOfYear, value: -11, to: thisSunday)
        else { return [] }

        return (0..<12).map { weekOffset in
            let weekStart = cal.date(byAdding: .weekOfYear, value: weekOffset, to: firstSunday)!
            return (0..<7).map { dayOffset in
                let day = cal.date(byAdding: .day, value: dayOffset, to: weekStart)!
                return day <= today ? day : nil
            }
        }
    }

    private func count(for date: Date?) -> Int {
        guard let date else { return -1 } // -1 = future (hide cell)
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return countsByDate[fmt.string(from: date), default: 0]
    }

    private func cellColor(count: Int) -> Color {
        switch count {
        case -1:  return .clear
        case 0:   return Color.secondary.opacity(0.12)
        case 1:   return Color.wazaAccent.opacity(0.5)
        default:  return Color.wazaAccent
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("12-Week Attendance")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: 4) {
                // Day-of-week labels (show M, W, F only to save space)
                VStack(alignment: .trailing, spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { symbolIndex in
                        Text([1, 3, 5].contains(symbolIndex) ? daySymbols[symbolIndex] : "")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .frame(width: 12, height: cellSize)
                    }
                }

                // Week columns
                HStack(spacing: cellSpacing) {
                    ForEach(0..<calendarWeeks.count, id: \.self) { weekIndex in
                        VStack(spacing: cellSpacing) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                let checkInCount = count(for: calendarWeeks[weekIndex][dayIndex])
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(cellColor(count: checkInCount))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 6) {
                Spacer()
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach([0.12, 0.5, 1.0], id: \.self) { opacity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(opacity < 0.2 ? Color.secondary.opacity(opacity) : Color.wazaAccent.opacity(opacity))
                        .frame(width: cellSize, height: cellSize)
                }
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .wazaCard()
    }
}

#Preview("With Attendance") {
    AttendanceCalendarView(attendance: ClassAttendanceModel.mocks)
        .padding()
}

#Preview("Empty") {
    AttendanceCalendarView(attendance: [])
        .padding()
}
