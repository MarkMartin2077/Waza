import SwiftUI
import SwiftfulUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let onAction {
                Text(actionTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.wazaAccent, in: Capsule())
                    .anyButton(.press) {
                        onAction()
                    }
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

#Preview("With Action") {
    EmptyStateView(
        icon: "figure.wrestling",
        title: "No Sessions Yet",
        subtitle: "Tap the button to log your first training session.",
        actionTitle: "Log Session",
        onAction: { }
    )
}

#Preview("Without Action") {
    EmptyStateView(
        icon: "trophy",
        title: "No Achievements",
        subtitle: "Keep training to unlock achievements.",
        actionTitle: nil,
        onAction: nil
    )
}
