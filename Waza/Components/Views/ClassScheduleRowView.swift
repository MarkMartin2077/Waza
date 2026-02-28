import SwiftUI

struct ClassScheduleRowView: View {
    let schedule: ClassScheduleModel?
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        if let schedule {
            HStack(spacing: 12) {
                Image(systemName: schedule.sessionType.iconName)
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .frame(width: 32, height: 32)
                    .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(schedule.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(schedule.formattedTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let onEdit {
                    Image(systemName: "pencil.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .anyButton { onEdit() }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .swipeActions(edge: .trailing) {
                if let onDelete {
                    Button("Delete", role: .destructive) { onDelete() }
                }
            }
        }
    }
}

#Preview("Full Data") {
    ClassScheduleRowView(
        schedule: .mock,
        onEdit: { print("Edit") },
        onDelete: { print("Delete") }
    )
    .padding()
}

#Preview("No Actions") {
    ClassScheduleRowView(
        schedule: .mock,
        onEdit: nil,
        onDelete: nil
    )
    .padding()
}

#Preview("Empty") {
    ClassScheduleRowView(
        schedule: nil,
        onEdit: nil,
        onDelete: nil
    )
    .padding()
}
