import SwiftUI

@MainActor
protocol AIInsightsInteractor: GlobalInteractor {
    var isAIAvailable: Bool { get }
    var aiUnavailabilityMessage: String { get }
    var allSessions: [BJJSessionModel] { get }
    var currentBeltEnum: BJJBelt { get }
    func streamWeeklySummary(sessions: [BJJSessionModel], belt: BJJBelt) -> AsyncThrowingStream<String, Error>
    func generateInsights(sessions: [BJJSessionModel], belt: BJJBelt) async throws -> [AITrainingInsight]
}

extension CoreInteractor: AIInsightsInteractor { }
