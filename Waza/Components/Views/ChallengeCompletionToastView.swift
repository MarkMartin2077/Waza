import SwiftUI

/// Lightweight top-of-screen toast that surfaces the title of a weekly challenge
/// the moment it's completed. Auto-dismisses after ~3 seconds.
struct ChallengeCompletionToastView: View {
    let title: String
    let onDismiss: () -> Void

    @State private var isVisible: Bool = false
    @State private var dismissTask: Task<Void, Never>?

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
                try? await Task.sleep(nanoseconds: 3_000_000_000)
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
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.subheadline)
                .foregroundStyle(Color.wazaAccent)

            VStack(alignment: .leading, spacing: 1) {
                Text("CHALLENGE COMPLETE")
                    .font(.wazaLabel)
                    .tracking(1.2)
                    .foregroundStyle(Color.wazaInk500)
                Text(title)
                    .font(.wazaBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.wazaInk900)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: .wazaCornerSmall)
                .fill(Color.wazaPaperHi)
                .overlay(
                    RoundedRectangle(cornerRadius: .wazaCornerSmall)
                        .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#Preview("Single line") {
    ChallengeCompletionToastView(
        title: "Train 3 times this week",
        onDismiss: {}
    )
    .background(Color.wazaPaper)
}

#Preview("Long title") {
    ChallengeCompletionToastView(
        title: "Promote a technique to the next stage",
        onDismiss: {}
    )
    .background(Color.wazaPaper)
}
