import Foundation

// MARK: - Remote Service Protocol

@MainActor
protocol RemoteBJJSessionService: Sendable {
    func getSessions(userId: String) async throws -> [BJJSessionModel]
    func saveSession(_ model: BJJSessionModel, userId: String) async throws
    func deleteSession(id: String, userId: String) async throws
}

// MARK: - Firebase Implementation

@MainActor
struct FirebaseBJJSessionService: RemoteBJJSessionService {
    private let collectionPath = "bjj_sessions"

    func getSessions(userId: String) async throws -> [BJJSessionModel] {
        // TODO: Implement using SwiftfulFirestore helpers
        // let path = "users/\(userId)/\(collectionPath)"
        // return try await Firestore.firestore().collection(path).getAllDocuments()
        return []
    }

    func saveSession(_ model: BJJSessionModel, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
        // let path = "users/\(userId)/\(collectionPath)"
        // try await Firestore.firestore().collection(path).document(model.sessionId).setData(from: model, merge: true)
    }

    func deleteSession(id: String, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
        // let path = "users/\(userId)/\(collectionPath)"
        // try await Firestore.firestore().collection(path).document(id).delete()
    }
}

// MARK: - Mock Implementation

@MainActor
final class MockRemoteBJJSessionService: RemoteBJJSessionService {
    var sessions: [BJJSessionModel] = []

    func getSessions(userId: String) async throws -> [BJJSessionModel] {
        sessions
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
