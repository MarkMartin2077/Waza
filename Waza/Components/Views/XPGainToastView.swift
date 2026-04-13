import SwiftUI

struct XPGainToastView: View {
    let data: XPToastData
    let accentColor: Color
    let onDismiss: () -> Void

    @State private var isVisible: Bool = false
    @State private var dismissTask: Task<Void, Never>?

    private var iconName: String {
        data.isFireRound ? "flame.fill" : "bolt.fill"
    }

    private var iconColor: Color {
        data.isFireRound ? .orange : accentColor
    }

    var body: some View {
        VStack {
            if isVisible {
                toastContent
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isVisible = true
            }
            dismissTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: data.isFireRound ? 3_500_000_000 : 2_500_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    isVisible = false
                }
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                onDismiss()
            }
        }
        .onDisappear {
            dismissTask?.cancel()
        }
    }

    private var toastContent: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text("+\(data.totalPoints) XP")
                        .font(.subheadline)
                        .fontWeight(.bold)

                    if let multiplierText = data.multiplierText {
                        Text(multiplierText)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(data.isFireRound ? .orange : accentColor)
                    }
                }

                if let breakdown = data.breakdownText {
                    Text(breakdown)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            data.isFireRound
                ? Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1)
                : nil
        )
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var text = "Earned \(data.totalPoints) XP"
        if data.isFireRound { text += ", fire round active" }
        if let multiplierText = data.multiplierText { text += ", \(multiplierText)" }
        return text
    }
}

#Preview("Base Session") {
    XPGainToastView(
        data: XPToastData(totalPoints: 10, leveledUp: false, newLevel: nil, newTitle: nil, breakdownText: nil, multiplierText: nil, isFireRound: false),
        accentColor: .cyan,
        onDismiss: { }
    )
}

#Preview("With Streak Multiplier") {
    XPGainToastView(
        data: XPToastData(totalPoints: 27, leveledUp: false, newLevel: nil, newTitle: nil, breakdownText: "Reflection + Mood", multiplierText: "1.5x Streak", isFireRound: false),
        accentColor: .cyan,
        onDismiss: { }
    )
}

#Preview("Fire Round") {
    XPGainToastView(
        data: XPToastData(totalPoints: 54, leveledUp: false, newLevel: nil, newTitle: nil, breakdownText: "Competition + Reflection", multiplierText: "3x Fire Round + Streak", isFireRound: true),
        accentColor: .cyan,
        onDismiss: { }
    )
}

#Preview("Check-In") {
    XPGainToastView(
        data: XPToastData(totalPoints: 5, leveledUp: false, newLevel: nil, newTitle: nil, breakdownText: nil, multiplierText: nil, isFireRound: false),
        accentColor: .cyan,
        onDismiss: { }
    )
}
