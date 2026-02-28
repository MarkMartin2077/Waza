import Foundation

@MainActor
final class MockRemoteBJJSessionService: RemoteBJJSessionService {
    var sessions: [BJJSessionModel]

    init(sessions: [BJJSessionModel] = []) {
        self.sessions = sessions
    }

    func getSessions(userId: String, limit: Int) async throws -> [BJJSessionModel] {
        Array(sessions.sorted { $0.date > $1.date }.prefix(limit))
    }

    func saveSession(_ model: BJJSessionModel, userId: String) async throws {
        if let index = sessions.firstIndex(where: { $0.sessionId == model.sessionId }) {
            sessions[index] = model
        } else {
            sessions.append(model)
        }
    }

    func deleteSession(id: String, userId: String) async throws {
        sessions.removeAll { $0.sessionId == id }
    }
}
