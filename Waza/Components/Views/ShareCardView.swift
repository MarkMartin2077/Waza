import SwiftUI

// MARK: - Card Type

enum ShareCardType {
    case sessionRecap(session: BJJSessionModel)
    case weekInReview(sessions: Int, hours: String, streakCount: Int)
    case levelUp(level: Int, title: String)
    case streakFlex(streakCount: Int, tier: StreakTier)
    case monthlyReport(month: String, sessions: Int, hours: String, streakDays: Int, level: Int, title: String)
}

// MARK: - Share Card View

struct ShareCardView: View {
    let cardType: ShareCardType
    let userName: String
    let accentColor: Color

    private let cardWidth: CGFloat = 360
    private let cardHeight: CGFloat = 640

    var body: some View {
        ZStack {
            background
            borderGlow
            VStack(spacing: 0) {
                topBar
                Spacer()
                cardContent
                Spacer()
                branding
            }
            .padding(28)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color(white: 0.06)

            // Subtle radial glow behind content
            RadialGradient(
                colors: [accentColor.opacity(0.08), .clear],
                center: .center,
                startRadius: 40,
                endRadius: 280
            )
        }
    }

    private var borderGlow: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(accentColor.opacity(0.2), lineWidth: 1)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            if !userName.isEmpty {
                Text(userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Text("WAZA")
                .font(.caption)
                .fontWeight(.heavy)
                .tracking(3)
                .foregroundStyle(accentColor)
        }
    }

    // MARK: - Content Router

    @ViewBuilder
    private var cardContent: some View {
        switch cardType {
        case .sessionRecap(let session):
            sessionRecapContent(session)
        case .weekInReview(let sessions, let hours, let streakCount):
            weekInReviewContent(sessions: sessions, hours: hours, streakCount: streakCount)
        case .levelUp(let level, let title):
            levelUpContent(level: level, title: title)
        case .streakFlex(let streakCount, let tier):
            streakFlexContent(streakCount: streakCount, tier: tier)
        case .monthlyReport(let month, let sessions, let hours, let streakDays, let level, let title):
            monthlyReportContent(month: month, sessions: sessions, hours: hours, streakDays: streakDays, level: level, title: title)
        }
    }

    // MARK: - Session Recap

    private func sessionRecapContent(_ session: BJJSessionModel) -> some View {
        VStack(spacing: 24) {
            // Icon with glow ring
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
                    .frame(width: 88, height: 88)
                Circle()
                    .fill(accentColor.opacity(0.08))
                    .frame(width: 88, height: 88)
                Image(systemName: session.sessionType.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(accentColor)
            }

            VStack(spacing: 8) {
                Text(session.sessionType.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                if let academy = session.academy {
                    Text(academy)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            HStack(spacing: 12) {
                statPill(icon: "clock.fill", value: session.durationFormatted)
                if session.roundsCount > 0 {
                    statPill(
                        icon: "repeat.circle.fill",
                        value: "\(session.roundsCount) \(session.roundsCount == 1 ? "round" : "rounds")"
                    )
                }
            }

            if !session.focusAreas.isEmpty {
                HStack(spacing: 6) {
                    ForEach(session.focusAreas.prefix(3), id: \.self) { area in
                        Text(area)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.07), in: Capsule())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            Text(session.dateFormatted)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
    }

    // MARK: - Week In Review

    private func weekInReviewContent(sessions: Int, hours: String, streakCount: Int) -> some View {
        VStack(spacing: 28) {
            Text("WEEK IN REVIEW")
                .font(.caption)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(accentColor)

            VStack(spacing: 6) {
                Text("\(sessions)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(sessions == 1 ? "session this week" : "sessions this week")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            divider

            HStack(spacing: 32) {
                statColumn(value: hours, label: "on the mats")
                if streakCount > 0 {
                    statColumn(
                        value: "\(streakCount)",
                        label: streakCount == 1 ? "day streak" : "day streak"
                    )
                }
            }
        }
    }

    // MARK: - Level Up

    private func levelUpContent(level: Int, title: String) -> some View {
        VStack(spacing: 24) {
            Text("LEVEL UP")
                .font(.caption)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(accentColor)

            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.25), lineWidth: 2)
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(accentColor.opacity(0.06))
                    .frame(width: 110, height: 110)
                VStack(spacing: 0) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(accentColor.opacity(0.5))
                    Text("\(level)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }

            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            let league = XPLevelSystem.league(forLevel: level)
            if league != .legend {
                Text(league.displayName.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1.5)
                    .foregroundStyle(accentColor.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(accentColor.opacity(0.1), in: Capsule())
            }
        }
    }

    // MARK: - Streak Flex

    private func streakFlexContent(streakCount: Int, tier: StreakTier) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "flame.fill")
                .font(.system(size: 52))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 6) {
                Text("\(streakCount)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(streakCount == 1 ? "day on the mats" : "days on the mats")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            if tier != .none {
                divider

                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                    Text("\(tier.displayName) Streak")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("+\(tier.bonusPercent)% XP")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .foregroundStyle(accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(accentColor.opacity(0.1), in: Capsule())
                .overlay(Capsule().stroke(accentColor.opacity(0.2), lineWidth: 1))
            }
        }
    }

    // MARK: - Monthly Report

    // swiftlint:disable:next function_parameter_count
    private func monthlyReportContent(month: String, sessions: Int, hours: String, streakDays: Int, level: Int, title: String) -> some View {
        VStack(spacing: 24) {
            Text("MONTHLY REPORT")
                .font(.caption)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(accentColor)

            Text(month)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                Text("\(sessions)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(sessions == 1 ? "session logged" : "sessions logged")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            divider

            HStack(spacing: 32) {
                statColumn(value: "\(hours)h", label: "on the mats")
                if streakDays > 0 {
                    statColumn(
                        value: "\(streakDays)",
                        label: streakDays == 1 ? "day streak" : "day streak"
                    )
                }
            }

            divider

            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.caption2)
                Text("Lvl \(level) · \(title)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(accentColor.opacity(0.1), in: Capsule())
            .overlay(Capsule().stroke(accentColor.opacity(0.2), lineWidth: 1))
        }
    }

    // MARK: - Shared Components

    private func statPill(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white.opacity(0.6))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.06), in: Capsule())
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 40, height: 1)
    }

    private var branding: some View {
        Text("waza.app")
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.25))
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Renderer

@MainActor
enum ShareCardRenderer {

    // Determine display scale from view context without using UIScreen.main
    private static func displayScale(for view: some View) -> CGFloat? {
        // Host the view to obtain a window/scene-derived screen scale when available
        let hosting = UIHostingController(rootView: view)
        // Force layout to attach view hierarchy without presenting
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
        // Attempt to resolve scale from the window scene's screen
        if let scale = hosting.view.window?.windowScene?.screen.scale {
            return scale
        }
        // Fallback to current trait collection's displayScale if available
        return hosting.traitCollection.displayScale
    }

    @MainActor
    static func render(card: ShareCardView) -> UIImage? {
        let renderer = ImageRenderer(content: card)
        // Prefer a context-derived display scale to avoid using UIScreen.main (deprecated)
        if let scale = ShareCardRenderer.displayScale(for: card) {
            renderer.scale = scale
        }
        return renderer.uiImage
    }
}

// MARK: - Previews

#Preview("Session Recap") {
    ShareCardView(
        cardType: .sessionRecap(session: .mock),
        userName: "Mark",
        accentColor: .cyan
    )
}

#Preview("Week In Review") {
    ShareCardView(
        cardType: .weekInReview(sessions: 4, hours: "6h 30m", streakCount: 12),
        userName: "Mark",
        accentColor: .cyan
    )
}

#Preview("Level Up") {
    ShareCardView(
        cardType: .levelUp(level: 8, title: "Scrapper 3"),
        userName: "Mark",
        accentColor: .cyan
    )
}

#Preview("Streak Flex — Diamond") {
    ShareCardView(
        cardType: .streakFlex(streakCount: 30, tier: .diamond),
        userName: "Mark",
        accentColor: .cyan
    )
}

#Preview("Streak Flex — Bronze") {
    ShareCardView(
        cardType: .streakFlex(streakCount: 5, tier: .bronze),
        userName: "Joe",
        accentColor: .cyan
    )
}

#Preview("Week — 1 Session") {
    ShareCardView(
        cardType: .weekInReview(sessions: 1, hours: "1h 30m", streakCount: 1),
        userName: "Alex",
        accentColor: .cyan
    )
}

#Preview("Monthly Report") {
    ShareCardView(
        cardType: .monthlyReport(month: "March 2026", sessions: 12, hours: "18.5", streakDays: 4, level: 8, title: "Scrapper 3"),
        userName: "Mark",
        accentColor: .cyan
    )
}
