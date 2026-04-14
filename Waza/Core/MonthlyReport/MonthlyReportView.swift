import SwiftUI
import SwiftfulUI

struct MonthlyReportView: View {
    @State var presenter: MonthlyReportPresenter

    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let data = presenter.reportData {
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
                } else if presenter.reportData != nil {
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
                monthPicker
                    .scaleAppear(delay: 0)
                heroCard(data: data)
                    .scaleAppear(delay: 0.03)
                if !data.isFirstMonth {
                    monthComparisonSection(data: data)
                        .scaleAppear(delay: 0.06)
                }
                streakSection(data: data)
                    .scaleAppear(delay: 0.08)
                if !data.typeBreakdown.isEmpty {
                    typeBreakdownSection(data: data)
                        .scaleAppear(delay: 0.1)
                }
                if !data.topFocusAreas.isEmpty {
                    topTechniquesSection(data: data)
                        .scaleAppear(delay: 0.12)
                }
                if data.avgPreMood != nil || data.avgPostMood != nil {
                    moodTrendsSection(data: data)
                        .scaleAppear(delay: 0.14)
                }
                if data.gymDistribution.count >= 2 {
                    gymDistributionSection(data: data)
                        .scaleAppear(delay: 0.16)
                }
                summaryFooterSection(data: data)
                    .scaleAppear(delay: 0.18)
            }
            .padding(16)
        }
    }

    private var emptyContent: some View {
        VStack(spacing: 16) {
            monthPicker

            VStack(spacing: 12) {
                Image(systemName: "figure.wrestling")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.wazaAccent.opacity(0.5))
                Text("No sessions this month")
                    .font(.headline)
                Text("Get on the mats and your report will be waiting!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Month Picker

    private var monthPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(presenter.monthOptions, id: \.monthsAgo) { option in
                    let isSelected = presenter.selectedMonthsAgo == option.monthsAgo
                    Text(option.label)
                        .font(.caption)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(isSelected ? Color.wazaAccent : Color(.systemGray6))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .anyButton {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                presenter.selectedMonthsAgo = option.monthsAgo
                            }
                        }
                }
            }
        }
    }

    // MARK: - Hero Card

    private func heroCard(data: MonthlyReportData) -> some View {
        VStack(spacing: 18) {
            heroHeader(data: data)

            HStack(spacing: 0) {
                heroStat(value: "\(data.totalSessions)", label: "sessions", icon: "figure.wrestling")
                Divider().frame(height: 40)
                heroStat(value: data.totalHoursFormatted, label: "hours", icon: "clock.fill")
                Divider().frame(height: 40)
                heroStat(value: "\(data.daysTrained)", label: "days", icon: "calendar")
                if data.longestStreakInMonth > 0 {
                    Divider().frame(height: 40)
                    heroStat(value: "\(data.longestStreakInMonth)", label: "streak", icon: "flame.fill")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.wazaAccent.opacity(0.15), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Monthly summary: \(data.monthLabel). \(data.totalSessions) sessions, \(data.totalHoursFormatted) hours, \(data.daysTrained) days trained")
    }

    /// Big gradient header — the visual identity anchor for this screen.
    /// Pairs the month name (large display) with the year (small, tracked caption).
    private func heroHeader(data: MonthlyReportData) -> some View {
        let parts = data.monthLabel.split(separator: " ", maxSplits: 1).map(String.init)
        let month = parts.first ?? data.monthLabel
        let year = parts.count > 1 ? parts[1] : ""

        return ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.74, blue: 0.31).opacity(0.35),  // amber
                    Color.wazaAccent.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 2) {
                if !year.isEmpty {
                    Text(year)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(3)
                        .foregroundStyle(.secondary)
                }
                Text(month.uppercased())
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(height: 120)
        .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
    }

    private func heroStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(Color.wazaAccent)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Month Comparison

    private func monthComparisonSection(data: MonthlyReportData) -> some View {
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

    private func deltaCard(delta: Int, label: String, formattedDelta: String) -> some View {
        let isPositive = delta > 0
        let isNeutral = delta == 0
        let color: Color = isNeutral ? .secondary : (isPositive ? .green : .red)
        let arrowIcon = isNeutral ? "minus" : (isPositive ? "arrow.up" : "arrow.down")
        let prefix = isPositive ? "+" : (isNeutral ? "" : "-")

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
            Text("vs prev month")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(prefix)\(formattedDelta) vs previous month")
    }

    // MARK: - Streak

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
                        Text("x\(area.count)")
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
                    moodPill(emoji: Mood.emoji(for: Int(pre.rounded())), label: "Pre-session", value: String(format: "%.1f", pre))
                }
                if let post = data.avgPostMood {
                    moodPill(emoji: Mood.emoji(for: Int(post.rounded())), label: "Post-session", value: String(format: "%.1f", post))
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
                    Text("(\(Mood.emoji(for: best.postMood)) \(best.postMood)/5)")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value) out of 5, \(emoji)")
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
                if data.goalsCompletedCount > 0 {
                    summaryRow(icon: "checkmark.seal.fill", label: "Goals completed this month", value: "\(data.goalsCompletedCount)")
                }
                if data.achievementsEarnedCount > 0 {
                    summaryRow(icon: "trophy.fill", label: "New achievements", value: "\(data.achievementsEarnedCount)")
                }
                if data.challengesCompletedCount > 0 {
                    summaryRow(icon: "flag.checkered", label: "Challenges completed", value: "\(data.challengesCompletedCount)")
                }
                if data.challengesSweepCount > 0 {
                    summaryRow(icon: "star.circle.fill", label: "Perfect challenge weeks", value: "\(data.challengesSweepCount)")
                }
                if data.techniquesPromotedCount > 0 {
                    summaryRow(icon: "chart.line.uptrend.xyaxis", label: "Techniques promoted", value: "\(data.techniquesPromotedCount)")
                }
                summaryRow(icon: "bolt.fill", label: "Current level", value: data.levelInfo.title)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
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
