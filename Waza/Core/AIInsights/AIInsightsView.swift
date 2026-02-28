import SwiftUI

struct AIInsightsView: View {
    @State var presenter: AIInsightsPresenter

    var body: some View {
        ZStack {
            mainContent
            if presenter.showErrorModal {
                errorOverlay
            }
        }
        .navigationTitle("AI Insights")
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        if !presenter.isAvailable {
            unavailableView
        } else {
            ScrollView {
                VStack(spacing: 28) {
                    summarySection
                    Divider()
                    insightsSection
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Unavailable

    private var unavailableView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Apple Intelligence Unavailable")
                .font(.title3)
                .fontWeight(.semibold)
            Text(presenter.unavailabilityMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Weekly Summary", systemImage: "text.quote")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Your coach reviews your recent sessions and gives you a personalised summary with one key action for your next training.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if presenter.isStreamingText || presenter.hasStreamedSummary {
                Text(presenter.streamingText.isEmpty ? "Thinking..." : presenter.streamingText)
                    .font(.body)
                    .foregroundStyle(presenter.isStreamingText ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .animation(.default, value: presenter.streamingText)
            }

            if presenter.isStreamingText {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Your AI coach is writing...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(presenter.hasStreamedSummary ? "Regenerate Summary" : "Generate Weekly Summary")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.accent, in: RoundedRectangle(cornerRadius: 12))
                    .anyButton(.press) {
                        presenter.onStreamSummaryTapped()
                    }
            }
        }
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Training Insights", systemImage: "lightbulb.fill")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("AI analyzes your recent sessions and reflections to surface 3 specific, actionable insights about your development.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if presenter.isGeneratingInsights {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Analyzing your training data...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else if !presenter.insights.isEmpty {
                ForEach(presenter.insights, id: \.title) { insight in
                    InsightCardView(insight: insight)
                }
                Text("Regenerate Insights")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .anyButton {
                        presenter.onGenerateInsightsTapped()
                    }
            } else {
                Text("Generate Training Insights")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.accent, in: RoundedRectangle(cornerRadius: 12))
                    .anyButton(.press) {
                        presenter.onGenerateInsightsTapped()
                    }
            }
        }
    }

    // MARK: - Error Overlay

    private var errorOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            CustomModalView(
                title: "Generation Failed",
                subtitle: presenter.errorMessage,
                primaryButtonTitle: "OK",
                primaryButtonAction: { presenter.onDismissError() },
                secondaryButtonTitle: "Dismiss",
                secondaryButtonAction: { presenter.onDismissError() }
            )
        }
    }
}

// MARK: - Insight Card Component

private struct InsightCardView: View {
    let insight: AITrainingInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: categoryIcon(insight.category))
                    .font(.subheadline)
                    .foregroundStyle(categoryColor(insight.category))
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(insight.category.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(categoryColor(insight.category).opacity(0.15))
                    .foregroundStyle(categoryColor(insight.category))
                    .clipShape(Capsule())
            }

            Text(insight.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.accent)
                Text(insight.actionItem)
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .background(.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "pattern":     return "repeat.circle.fill"
        case "strength":    return "star.fill"
        case "opportunity": return "arrow.up.circle.fill"
        case "warning":     return "exclamationmark.triangle.fill"
        default:            return "lightbulb.fill"
        }
    }

    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "pattern":     return .blue
        case "strength":    return .green
        case "opportunity": return .orange
        case "warning":     return .red
        default:            return .accent
        }
    }
}

// MARK: - CoreBuilder Extension

extension CoreBuilder {
    func aiInsightsView(router: AnyRouter) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        let presenter = AIInsightsPresenter(
            interactor: interactor,
            router: coreRouter
        )
        return AIInsightsView(presenter: presenter)
    }
}

extension CoreRouter {
    func showAIInsightsView() {
        router.showScreen(.push) { router in
            builder.aiInsightsView(router: router)
        }
    }
}

// MARK: - Previews

#Preview("AI Insights") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.aiInsightsView(router: router)
    }
}
