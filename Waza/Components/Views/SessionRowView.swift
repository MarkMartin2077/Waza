import SwiftUI

struct SessionRowView: View {
    let session: BJJSessionModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.iconName)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 40, height: 40)
                .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(session.sessionType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 6) {
                    Text(session.dateFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(session.durationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
