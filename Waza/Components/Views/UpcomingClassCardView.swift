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

                    HStack(spacing: 4) {
                        Text(gym.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(schedule.formattedTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: schedule.sessionType.iconName)
                    .font(.title2)
                    .foregroundStyle(.accent)
                    .frame(width: 44, height: 44)
                    .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .anyButton(.press) {
                onTap?()
            }
        }
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
