import Foundation

@MainActor
protocol RemoteBJJSessionService: Sendable {
    func getSessions(userId: String, limit: Int) async throws -> [BJJSessionModel]
    func saveSession(_ model: BJJSessionModel, userId: String) async throws
    func deleteSession(id: String, userId: String) async throws
}
