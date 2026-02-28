import Foundation
import FoundationModels

struct AIEncouragementContext {
    let userName: String
    let streakCount: Int
    let classesThisWeek: Int
    let weeklyTarget: Int
    let belt: BJJBelt
    let totalAttendance: Int
}

@available(iOS 26.0, *)
@Observable
@MainActor
class AIInsightsManager {

    // MARK: - Availability

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    var unavailabilityMessage: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return ""
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return "Your device does not support Apple Intelligence. A device with an A17 Pro chip or later is required."
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence is not enabled. Go to Settings → Apple Intelligence & Siri to turn it on."
            case .modelNotReady:
                return "Apple Intelligence is still downloading. Please try again in a few minutes."
            default:
                return "Apple Intelligence is not available right now. Please check your device settings."
            }
        }
    }

    // MARK: - Check-In Encouragement (Streaming)

    func generateCheckInEncouragement(context: AIEncouragementContext) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task { @MainActor in
                guard SystemLanguageModel.default.availability == .available else {
                    continuation.finish(throwing: AIInsightsError.notAvailable)
                    return
                }
                do {
                    let aiSession = LanguageModelSession()
                    let progressText = context.weeklyTarget > 0
                        ? "\(context.classesThisWeek)/\(context.weeklyTarget) classes this week"
                        : "\(context.classesThisWeek) classes this week"
                    let prompt = """
                    You are a warm, encouraging BJJ coach. Write a 1–2 sentence personalised \
                    check-in message addressed to \(context.userName), a \(context.belt.displayName) belt athlete who just arrived at the gym. \
                    Use their name naturally in the message. \
                    Details: \(progressText), \(context.streakCount) day training streak, \(context.totalAttendance) total classes attended. \
                    Be specific, upbeat and brief.
                    """
                    for try await partial in aiSession.streamResponse(to: prompt) {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: AIInsightsError.generationFailed(error))
                }
            }
        }
    }

    // MARK: - Weekly Summary (Streaming with Tools)

    func streamWeeklySummary(
        sessions: [BJJSessionModel],
        belt: BJJBelt
    ) -> AsyncThrowingStream<String, Error> {
        // Pre-format @Model data to Sendable [String] before crossing into Task
        let formattedSessions = sessions.map { formatSession($0) }
        let formattedReflections = sessions.compactMap { formatReflection($0) }
        let statsText = formatStats(sessions: sessions)

        return AsyncThrowingStream { continuation in
            Task { @MainActor in
                do {
                    let tools: [any Tool] = [
                        FetchRecentSessionsTool(formattedSessions: formattedSessions),
                        FetchTrainingStatsTool(statsText: statsText),
                        FetchRecentReflectionsTool(formattedReflections: formattedReflections)
                    ]
                    let aiSession = LanguageModelSession(tools: tools)
                    let prompt = """
                    You are a supportive BJJ coach for a \(belt.displayName) belt athlete. \
                    Use the available tools to fetch their recent training data, then write a \
                    brief personalised summary in second person. Two short paragraphs max — \
                    acknowledge their recent effort and end with one specific actionable \
                    suggestion for their next session.
                    """
                    for try await partial in aiSession.streamResponse(to: prompt) {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Structured Insights Generation

    // Uses pre-formatted prompt rather than tools — combining tool calling with
    // @Generable structured output triggers GenerationError in Foundation Models.
    func generateInsights(
        sessions: [BJJSessionModel],
        belt: BJJBelt
    ) async throws -> [AITrainingInsight] {
        let aiSession = LanguageModelSession()
        let prompt = buildInsightsPrompt(sessions: sessions, belt: belt)
        let response = try await aiSession.respond(to: prompt, generating: AITrainingInsights.self)
        return response.content.insights
    }

    // MARK: - Insights Prompt Builder

    private func buildInsightsPrompt(sessions: [BJJSessionModel], belt: BJJBelt) -> String {
        let recent = Array(sessions.prefix(20))
        let statsText = formatStats(sessions: sessions)
        let reflections = recent.compactMap { formatReflection($0) }.prefix(5).joined(separator: "\n")
        let recentSessions = recent.prefix(10).map { formatSession($0) }.joined(separator: "\n")

        return """
        You are an expert BJJ coach. Analyse this \(belt.displayName) belt athlete's training data \
        and produce exactly 3 specific, actionable insights. Base each insight directly on the data \
        provided — do not give generic BJJ advice. Each insight must cover a different aspect: \
        patterns, strengths, or opportunities.

        Training stats:
        \(statsText)

        Recent sessions:
        \(recentSessions.isEmpty ? "None logged yet." : recentSessions)

        Self-reflections:
        \(reflections.isEmpty ? "None logged yet." : reflections)
        """
    }

    // MARK: - Data Formatting Helpers

    private func formatSession(_ session: BJJSessionModel) -> String {
        let date = session.date.formatted(date: .abbreviated, time: .omitted)
        let duration = Int(session.duration / 60)
        let focus = session.focusAreas.isEmpty ? "General" : session.focusAreas.joined(separator: ", ")
        var parts = [
            "Date: \(date)",
            "Type: \(session.sessionType.displayName)",
            "Duration: \(duration) min",
            "Focus: \(focus)"
        ]
        if let notes = session.notes, !notes.isEmpty {
            parts.append("Notes: \(notes)")
        }
        return parts.joined(separator: " | ")
    }

    private func formatReflection(_ session: BJJSessionModel) -> String? {
        let parts: [String] = [
            session.whatWorkedWell.map { "What worked: \($0)" },
            session.needsImprovement.map { "Needs improvement: \($0)" },
            session.keyInsights.map { "Key insight: \($0)" }
        ].compactMap { $0 }

        guard !parts.isEmpty else { return nil }
        let date = session.date.formatted(date: .abbreviated, time: .omitted)
        return "[\(date)] \(parts.joined(separator: " | "))"
    }

    private func formatStats(sessions: [BJJSessionModel]) -> String {
        guard !sessions.isEmpty else {
            return "No sessions logged yet."
        }
        let totalMinutes = Int(sessions.reduce(0) { $0 + $1.duration } / 60)
        let avgMinutes = totalMinutes / sessions.count
        let typeCounts = Dictionary(grouping: sessions, by: \.sessionType)
            .mapValues(\.count)
            .sorted { $0.value > $1.value }
            .map { "\($0.key.displayName): \($0.value)" }
            .joined(separator: ", ")
        return """
        Total sessions: \(sessions.count) | \
        Total training time: \(totalMinutes) min | \
        Average session: \(avgMinutes) min | \
        Session types: \(typeCounts)
        """
    }
}

// MARK: - Error Type

enum AIInsightsError: LocalizedError {
    case notAvailable
    case generationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Intelligence is not available on this device."
        case .generationFailed(let error):
            return "Generation failed: \(error.localizedDescription)"
        }
    }
}
