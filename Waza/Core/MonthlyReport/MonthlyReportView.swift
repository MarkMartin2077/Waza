import SwiftUI
import SwiftfulUI

struct MonthlyReportView: View {
    @State var presenter: MonthlyReportPresenter

    var body: some View {
        Group {
            if let data = presenter.reportData {
                reportContent(data: data)
            } else {
                emptyContent
            }
        }
        .navigationTitle("Training Report")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let image = presenter.shareCardImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("My \(presenter.reportData?.monthLabel ?? "") Report", image: Image(uiImage: image))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(Color.wazaAccent)
                    }
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(Color.wazaAccent)
                        .anyButton {
                            presenter.onShareTapped()
                        }
                }
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Report Content

    private func reportContent(data: MonthlyReportData) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard(data: data)
                    .scaleAppear(delay: 0)
                headlineStatsSection(data: data)
                    .scaleAppear(delay: 0.05)
                if !data.isFirstMonth {
                    monthComparisonSection(data: data)
                        .scaleAppear(delay: 0.08)
                }
                streakSection(data: data)
                    .scaleAppear(delay: 0.1)
                if !data.typeBreakdown.isEmpty {
                    typeBreakdownSection(data: data)
                        .scaleAppear(delay: 0.13)
                }
                if !data.topFocusAreas.isEmpty {
                    topTechniquesSection(data: data)
                        .scaleAppear(delay: 0.16)
                }
                if data.avgPreMood != nil || data.avgPostMood != nil {
                    moodTrendsSection(data: data)
                        .scaleAppear(delay: 0.19)
                }
                if data.gymDistribution.count >= 2 {
                    gymDistributionSection(data: data)
                        .scaleAppear(delay: 0.22)
                }
                summaryFooterSection(data: data)
                    .scaleAppear(delay: 0.25)
            }
            .padding(16)
        }
    }

    private var emptyContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundStyle(Color.wazaAccent.opacity(0.5))
            Text("No report available")
                .font(.headline)
            Text("Log sessions to see your monthly training report.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Header Card

    private func headerCard(data: MonthlyReportData) -> some View {
        VStack(spacing: 6) {
            Text(data.monthLabel.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(Color.wazaAccent)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Training Report")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            let startFormatted = data.dateRange.start.shortFormatted
            let endFormatted = data.dateRange.end.shortFormatted
            Text("\(startFormatted) – \(endFormatted)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Headline Stats (2x2 grid)

    private func headlineStatsSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(value: "\(data.totalSessions)", label: "Sessions", icon: "figure.wrestling")
                statCard(value: data.totalHoursFormatted, label: "Hours", icon: "clock.fill")
                statCard(value: "\(data.avgDurationMinutes)m", label: "Avg Duration", icon: "timer")
                statCard(value: "\(data.daysTrained)", label: "Days Trained", icon: "calendar")
            }
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
            Text(value)
                .font(.wazaTitle)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Month Comparison

    private func monthComparisonSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("vs Previous Month")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                deltaCard(
                    delta: data.sessionsDelta,
                    label: "Sessions",
                    formattedDelta: "\(abs(data.sessionsDelta))"
                )
                deltaCard(
                    delta: data.hoursDelta > 0 ? 1 : (data.hoursDelta < 0 ? -1 : 0),
                    label: "Hours",
                    formattedDelta: String(format: "%.1f", abs(data.hoursDelta))
                )
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func deltaCard(delta: Int, label: String, formattedDelta: String) -> some View {
        let isPositive = delta > 0
        let isNeutral = delta == 0
        let color: Color = isNeutral ? .secondary : (isPositive ? .green : .red)
        let arrowIcon = isNeutral ? "minus" : (isPositive ? "arrow.up" : "arrow.down")
        let prefix = isNeutral ? "" : (isPositive ? "+" : "-")

        return VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: arrowIcon)
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(prefix)\(formattedDelta)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Streak Section

    private func streakSection(data: MonthlyReportData) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 44, height: 44)
                .background(Color.wazaAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Best Streak")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(data.longestStreakInMonth) \(data.longestStreakInMonth == 1 ? "day" : "days") in a row")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Type Breakdown

    private func typeBreakdownSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Types")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                ForEach(data.typeBreakdown, id: \.sessionType) { stat in
                    typeRow(stat: stat)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func typeRow(stat: TypeStat) -> some View {
        VStack(spacing: 4) {
            HStack {
                Label(stat.sessionType.displayName, systemImage: stat.sessionType.iconName)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(stat.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.wazaAccent)
                        .frame(width: geo.size.width * stat.percentage, height: 6)
                        .animation(.easeOut(duration: 0.5), value: stat.percentage)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Top Techniques

    private func topTechniquesSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Focus Areas")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                ForEach(Array(data.topFocusAreas.prefix(5).enumerated()), id: \.offset) { index, area in
                    HStack(spacing: 10) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.wazaAccent)
                            .frame(width: 20, alignment: .center)
                        Text(area.name)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("×\(area.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Mood Trends

    private func moodTrendsSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Trends")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                if let pre = data.avgPreMood {
                    moodPill(emoji: moodEmoji(for: pre), label: "Pre-session", value: String(format: "%.1f", pre))
                }
                if let post = data.avgPostMood {
                    moodPill(emoji: moodEmoji(for: post), label: "Post-session", value: String(format: "%.1f", post))
                }
            }

            if let best = data.bestTrainingDay {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text("Best day: \(best.date.relativeFormatted)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("(\(moodEmoji(for: Double(best.postMood))) \(best.postMood)/5)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func moodPill(emoji: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title3)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func moodEmoji(for value: Double) -> String {
        switch value {
        case ..<2:   return "😞"
        case ..<3:   return "😐"
        case ..<4:   return "🙂"
        case ..<4.5: return "😊"
        default:     return "🤩"
        }
    }

    // MARK: - Gym Distribution

    private func gymDistributionSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gyms Visited")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                ForEach(data.gymDistribution, id: \.name) { gym in
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.wazaAccent)
                            .font(.subheadline)
                        Text(gym.name)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("^[\(gym.count) session](inflect: true)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Summary Footer

    private func summaryFooterSection(data: MonthlyReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlights")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                summaryRow(
                    icon: "checkmark.seal.fill",
                    label: "Goals completed",
                    value: "\(data.goalsCompletedCount)"
                )
                summaryRow(
                    icon: "trophy.fill",
                    label: "Achievements earned",
                    value: "\(data.achievementsEarnedCount)"
                )
                summaryRow(
                    icon: "bolt.fill",
                    label: "Current level",
                    value: data.levelInfo.title
                )
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color.wazaAccent)
                .font(.subheadline)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - CoreBuilder Extension

extension CoreBuilder {
    func monthlyReportView(router: AnyRouter) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        let presenter = MonthlyReportPresenter(interactor: interactor, router: coreRouter)
        return MonthlyReportView(presenter: presenter)
    }
}

// MARK: - CoreRouter Extension

extension CoreRouter {
    func showMonthlyReportView() {
        router.showScreen(.push) { router in
            self.builder.monthlyReportView(router: router)
        }
    }
}

// MARK: - Previews

#Preview("Full Data") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        NavigationStack {
            builder.monthlyReportView(router: router)
        }
    }
}

#Preview("Empty Month") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        NavigationStack {
            builder.monthlyReportView(router: router)
        }
    }
}
