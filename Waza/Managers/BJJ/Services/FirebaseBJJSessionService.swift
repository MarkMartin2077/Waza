import FirebaseFirestore
import SwiftfulFirestore

@MainActor
struct FirebaseBJJSessionService: RemoteBJJSessionService {
    private let collectionPath = "bjj_sessions"

    private func collection(for userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection(collectionPath)
    }

    func getSessions(userId: String) async throws -> [BJJSessionModel] {
        try await collection(for: userId).getAllDocuments()
    }

    func saveSession(_ model: BJJSessionModel, userId: String) async throws {
        try await collection(for: userId).setDocument(id: model.sessionId, document: model)
    }

    func deleteSession(id: String, userId: String) async throws {
        try await collection(for: userId).deleteDocument(id: id)
    }
}
