import SwiftUI

struct SessionRowView: View {
    let session: BJJSessionModel
    let accentColor: Color?

    private var resolvedAccent: Color { accentColor ?? .accentColor }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: session.sessionType.iconName)
                .font(.subheadline)
                .foregroundStyle(resolvedAccent)
                .frame(width: 32, height: 32)
                .background(resolvedAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(session.sessionType.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(session.durationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !session.focusAreas.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(session.focusAreas.prefix(2), id: \.self) { area in
                            Text(area)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5), in: Capsule())
                                .foregroundStyle(.secondary)
                        }
                        if session.focusAreas.count > 2 {
                            Text("+\(session.focusAreas.count - 2)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Text(relativeDate(session.date))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        if daysAgo < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview("With focus areas") {
    SessionRowView(session: .mock, accentColor: .blue)
        .padding()
}

#Preview("No accent") {
    SessionRowView(session: .mock, accentColor: nil)
        .padding()
}
