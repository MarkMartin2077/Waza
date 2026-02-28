import SwiftUI

struct StreakHeroView: View {
    let streakCount: Int?
    let accentColor: Color?
    @State private var isAnimated: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Text(streakCount.map { "\($0)" } ?? "—")
                .font(.wazaHero)
                .foregroundStyle(accentColor ?? .primary)
                .scaleEffect(isAnimated ? 1 : 0.7)
                .opacity(isAnimated ? 1 : 0)

            Text("DAY STREAK")
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
                .opacity(isAnimated ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1)) {
                isAnimated = true
            }
        }
    }
}

#Preview("Active streak") {
    StreakHeroView(streakCount: 42, accentColor: .blue)
        .padding()
}

#Preview("No streak") {
    StreakHeroView(streakCount: 0, accentColor: .blue)
        .padding()
}

#Preview("Loading") {
    StreakHeroView(streakCount: nil, accentColor: nil)
        .padding()
}
