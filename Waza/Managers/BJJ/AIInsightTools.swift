import Foundation
import FoundationModels

// MARK: - Fetch Recent Sessions

/// Lets the model request any number of the athlete's recent training sessions.
/// Data is pre-formatted to Sendable strings before the tool is created.
@available(iOS 26.0, *)
struct FetchRecentSessionsTool: Tool {
    var name: String = "fetchRecentSessions"
    var description: String = "Fetches the athlete's recent BJJ training sessions. Each entry includes the date, session type, duration, focus areas trained, and general notes. Provide the number of sessions to retrieve (1–30)."

    @Generable()
    struct Arguments {
        var count: Int
    }

    let formattedSessions: [String]

    func call(arguments: Arguments) async throws -> String {
        let clamped = max(1, min(arguments.count, formattedSessions.count))
        let subset = Array(formattedSessions.prefix(clamped))
        guard !subset.isEmpty else {
            return "No sessions logged yet."
        }
        return subset.joined(separator: "\n\n")
    }
}

// MARK: - Fetch Training Stats

/// Returns aggregate training statistics so the model can understand overall volume and frequency.
@available(iOS 26.0, *)
struct FetchTrainingStatsTool: Tool {
    var name: String = "fetchTrainingStats"
    var description: String = "Returns aggregate training statistics: total sessions logged, total hours trained, average session duration, and session type breakdown. No arguments needed."

    @Generable()
    struct Arguments {}

    let statsText: String

    func call(arguments: Arguments) async throws -> String {
        return statsText
    }
}

// MARK: - Fetch Recent Reflections

/// Returns the athlete's own written reflections — what worked, what needs improvement, key insights.
/// This is often the most valuable signal for personalised coaching.
@available(iOS 26.0, *)
struct FetchRecentReflectionsTool: Tool {
    var name: String = "fetchRecentReflections"
    var description: String = "Returns the athlete's self-written reflections from recent sessions: what worked well, what needs improvement, and key insights in their own words. Provide the number of reflections to fetch (1–20)."

    @Generable()
    struct Arguments {
        var count: Int
    }

    let formattedReflections: [String]

    func call(arguments: Arguments) async throws -> String {
        let clamped = max(1, min(arguments.count, formattedReflections.count))
        let subset = Array(formattedReflections.prefix(clamped))
        guard !subset.isEmpty else {
            return "No self-reflections logged yet."
        }
        return subset.joined(separator: "\n\n")
    }
}
