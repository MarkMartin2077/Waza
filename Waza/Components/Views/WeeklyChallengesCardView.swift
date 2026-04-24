import SwiftUI

struct WeeklyChallengesCardView: View {
    let challenges: [WeeklyChallengeModel]
    let completedCount: Int
    let accentColor: Color

    var body: some View {
        VStack(spacing: 12) {
            headerRow
            if challenges.isEmpty {
                emptyState
            } else {
                ForEach(challenges) { challenge in
                    challengeRow(challenge)
                }
            }
        }
        .padding(14)
        .wazaCard()
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text("Weekly Challenges")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            completionBadge
        }
    }

    private var completionBadge: some View {
        let allDone = completedCount >= challenges.count && !challenges.isEmpty
        return Text("\(completedCount)/\(challenges.count)")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(allDone ? .white : accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(allDone ? Color.green : accentColor.opacity(0.15), in: Capsule())
    }

    // MARK: - Challenge Row

    private func challengeRow(_ challenge: WeeklyChallengeModel) -> some View {
        HStack(spacing: 10) {
            // Category-tinted left accent bar — gives each challenge type a visual identity.
            // Hidden when complete so the green checkmark + strikethrough can do the talking.
            if !challenge.isCompleted {
                RoundedRectangle(cornerRadius: 2)
                    .fill(challenge.challengeType.category.accentColor)
                    .frame(width: 3)
            } else {
                Color.clear.frame(width: 3)
            }

            completionIcon(isCompleted: challenge.isCompleted)

            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.subheadline)
                    .strikethrough(challenge.isCompleted, color: .secondary)
                    .foregroundStyle(challenge.isCompleted ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(challenge.progressText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Progress bar hidden when complete — the green checkmark + strikethrough
            // already communicate "done"; a full-width green bar on top of that was
            // reading as active progress and looked like a visual bug.
            if !challenge.isCompleted {
                progressBar(for: challenge)
                    .frame(width: 56)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(for: challenge))
    }

    // MARK: - Completion Icon

    private func completionIcon(isCompleted: Bool) -> some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.body)
            .foregroundStyle(isCompleted ? .green : Color(.systemGray3))
    }

    // MARK: - Progress Bar

    private func progressBar(for challenge: WeeklyChallengeModel) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                Capsule()
                    .fill(challenge.isCompleted ? Color.green : accentColor)
                    .frame(width: geo.size.width * challenge.progress, height: 4)
                    .animation(.easeOut(duration: 0.4), value: challenge.progress)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Text("No challenges this week")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Accessibility

    private func accessibilityLabel(for challenge: WeeklyChallengeModel) -> String {
        let status = challenge.isCompleted ? "Completed" : "In progress, \(challenge.progressText)"
        return "\(challenge.title). \(status)."
    }
}

// MARK: - Previews

#Preview("All Incomplete") {
    let weekStart = WeeklyChallengeModel.currentWeekStart()
    WeeklyChallengesCardView(
        challenges: [
            WeeklyChallengeModel(
                challengeId: "1",
                weekStartDate: weekStart,
                challengeType: .trainXTimes,
                title: "Train 3 times this week",
                targetValue: 3,
                currentValue: 1
            ),
            WeeklyChallengeModel(
                challengeId: "2",
                weekStartDate: weekStart,
                challengeType: .logFullReflection,
                title: "Write a full session reflection",
                targetValue: 1,
                currentValue: 0
            ),
            WeeklyChallengeModel(
                challengeId: "3",
                weekStartDate: weekStart,
                challengeType: .logMoodBothWays,
                title: "Rate your mood before & after a session",
                targetValue: 1,
                currentValue: 0
            )
        ],
        completedCount: 0,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Partial Complete — 2/3") {
    let weekStart = WeeklyChallengeModel.currentWeekStart()
    WeeklyChallengesCardView(
        challenges: [
            WeeklyChallengeModel(
                challengeId: "1",
                weekStartDate: weekStart,
                challengeType: .trainXTimes,
                title: "Train 3 times this week",
                targetValue: 3,
                currentValue: 3,
                isCompleted: true,
                completedDate: Date()
            ),
            WeeklyChallengeModel(
                challengeId: "2",
                weekStartDate: weekStart,
                challengeType: .miniStreak,
                title: "Train 2 days in a row this week",
                targetValue: 2,
                currentValue: 2,
                isCompleted: true,
                completedDate: Date()
            ),
            WeeklyChallengeModel(
                challengeId: "3",
                weekStartDate: weekStart,
                challengeType: .newFocusArea,
                title: "Try a technique you haven't trained recently",
                targetValue: 1,
                currentValue: 0
            )
        ],
        completedCount: 2,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Full Sweep — All Complete") {
    let mocks = WeeklyChallengeModel.mocks
    WeeklyChallengesCardView(
        challenges: mocks,
        completedCount: mocks.filter(\.isCompleted).count,
        accentColor: .cyan
    )
    .padding()
}

#Preview("Single Challenge") {
    let weekStart = WeeklyChallengeModel.currentWeekStart()
    WeeklyChallengesCardView(
        challenges: [
            WeeklyChallengeModel(
                challengeId: "1",
                weekStartDate: weekStart,
                challengeType: .trainDuration,
                title: "Log a 90+ minute session",
                targetValue: 90,
                currentValue: 0
            )
        ],
        completedCount: 0,
        accentColor: .cyan
    )
    .padding()
}
