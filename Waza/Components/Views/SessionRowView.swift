import SwiftUI

struct SessionRowView: View {
    let session: BJJSessionModel
    let accentColor: Color?

    private var resolvedAccent: Color { accentColor ?? .accentColor }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.iconName)
                .font(.title3)
                .foregroundStyle(resolvedAccent)
                .frame(width: 44, height: 44)
                .background(resolvedAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(resolvedAccent.opacity(0.2), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionType.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Text(session.dateFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(session.durationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !session.focusAreas.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(session.focusAreas.prefix(2), id: \.self) { area in
                            Text(area)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(resolvedAccent.opacity(0.1), in: Capsule())
                                .foregroundStyle(resolvedAccent)
                        }
                        if session.focusAreas.count > 2 {
                            Text("+\(session.focusAreas.count - 2)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
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
