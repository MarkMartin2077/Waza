import SwiftUI

@Observable
@MainActor
class AIInsightsPresenter {
    private let interactor: AIInsightsInteractor
    private let router: AIInsightsRouter

    var isAvailable: Bool { interactor.isAIAvailable }
    var unavailabilityMessage: String { interactor.aiUnavailabilityMessage }

    // Streaming summary
    var streamingText: String = ""
    var isStreamingText: Bool = false
    var hasStreamedSummary: Bool = false

    // Structured insights
    var insights: [AITrainingInsight] = []
    var isGeneratingInsights: Bool = false
    var hasGeneratedInsights: Bool = false

    // Error state
    var showErrorModal: Bool = false
    var errorMessage: String = ""

    init(interactor: AIInsightsInteractor, router: AIInsightsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onStreamSummaryTapped() {
        guard isAvailable && !isStreamingText else { return }
        interactor.trackEvent(event: Event.streamSummaryTapped)
        streamSummary()
    }

    func onGenerateInsightsTapped() {
        guard isAvailable && !isGeneratingInsights else { return }
        interactor.trackEvent(event: Event.generateInsightsTapped)
        generateInsights()
    }

    func onDismissError() {
        showErrorModal = false
        errorMessage = ""
    }

    // MARK: - Private

    private func streamSummary() {
        isStreamingText = true
        streamingText = ""
        Task {
            do {
                let sessions = interactor.allSessions
                let belt = interactor.currentBeltEnum
                let stream = interactor.streamWeeklySummary(sessions: sessions, belt: belt)
                for try await chunk in stream {
                    streamingText = chunk
                }
                hasStreamedSummary = true
                interactor.trackEvent(event: Event.summaryStreamed)
            } catch {
                errorMessage = error.localizedDescription
                showErrorModal = true
                interactor.trackEvent(event: Event.streamFailed(error: error))
            }
            isStreamingText = false
        }
    }

    private func generateInsights() {
        isGeneratingInsights = true
        Task {
            do {
                let sessions = interactor.allSessions
                let belt = interactor.currentBeltEnum
                insights = try await interactor.generateInsights(sessions: sessions, belt: belt)
                hasGeneratedInsights = true
                interactor.trackEvent(event: Event.insightsGenerated(count: insights.count))
            } catch {
                errorMessage = error.localizedDescription
                showErrorModal = true
                interactor.trackEvent(event: Event.insightsFailed(error: error))
            }
            isGeneratingInsights = false
        }
    }
}

extension AIInsightsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case streamSummaryTapped
        case generateInsightsTapped
        case summaryStreamed
        case insightsGenerated(count: Int)
        case streamFailed(error: Error)
        case insightsFailed(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:              return "AIInsights_Appear"
            case .streamSummaryTapped:   return "AIInsights_StreamSummary_Tap"
            case .generateInsightsTapped: return "AIInsights_GenerateInsights_Tap"
            case .summaryStreamed:        return "AIInsights_Summary_Streamed"
            case .insightsGenerated:     return "AIInsights_Insights_Generated"
            case .streamFailed:          return "AIInsights_Stream_Fail"
            case .insightsFailed:        return "AIInsights_Insights_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .insightsGenerated(count: let count):
                return ["count": count]
            case .streamFailed(error: let error), .insightsFailed(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .streamFailed, .insightsFailed: return .severe
            default: return .analytic
            }
        }
    }
}
