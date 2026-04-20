import SwiftUI

struct SessionRowView: View {
    let session: BJJSessionModel
    let accentColor: Color?

    private var resolvedAccent: Color { accentColor ?? .accentColor }

    /// Deterministic rotation derived from the session ID so stamps don't jitter on rerender.
    private var hankoRotation: Double {
        let hash = session.id.hashValue
        return Double(hash % 7) - 3 // range: -3 to +3 degrees
    }

    var body: some View {
        HStack(spacing: 10) {
            HankoView(
                kanji: session.sessionType.kanji,
                size: 36,
                rotation: hankoRotation,
                color: resolvedAccent
            )

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
        .wazaCard()
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
