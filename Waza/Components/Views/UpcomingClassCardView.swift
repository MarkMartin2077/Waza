import SwiftUI

struct UpcomingClassCardView: View {
    let schedule: ClassScheduleModel?
    let gym: GymLocationModel?
    let onTap: (() -> Void)?

    var body: some View {
        if let schedule, let gym {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Next Class", systemImage: "calendar.badge.clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(schedule.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(gym.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(timeText(for: schedule))
                        .font(.caption)
                        .foregroundStyle(Color.wazaAccent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: schedule.sessionType.iconName)
                    .font(.subheadline)
                    .foregroundStyle(Color.wazaAccent)
                    .frame(width: 32, height: 32)
                    .background(Color.wazaAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .anyButton(.press) {
                onTap?()
            }
        }
    }

    private func timeText(for schedule: ClassScheduleModel) -> String {
        let date = schedule.nextOccurrence
        let calendar = Calendar.current
        let time = formattedTime(for: schedule)
        if calendar.isDateInToday(date) {
            return "Today at \(time)"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow at \(time)"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return "\(formatter.string(from: date)) at \(time)"
        }
    }

    private func formattedTime(for schedule: ClassScheduleModel) -> String {
        let hour = schedule.startHour
        let minute = schedule.startMinute
        let isPM = hour >= 12
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):\(String(format: "%02d", minute)) \(isPM ? "PM" : "AM")"
    }
}

#Preview("Full Data") {
    UpcomingClassCardView(
        schedule: .mock,
        gym: .mock,
        onTap: { print("Tapped") }
    )
    .padding()
}

#Preview("No Data") {
    UpcomingClassCardView(
        schedule: nil,
        gym: nil,
        onTap: nil
    )
    .padding()
}
