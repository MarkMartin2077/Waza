import Foundation
#if !MOCK
import FirebaseFirestore
#endif

@MainActor
struct FirebaseBJJSessionService: RemoteBJJSessionService {
    private let collectionPath = "bjj_sessions"

    func getSessions(userId: String) async throws -> [BJJSessionModel] {
        #if !MOCK
        let snapshot = try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: BJJSessionModel.self) }
        #else
        return []
        #endif
    }

    func saveSession(_ model: BJJSessionModel, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(model.sessionId).setData(from: model, merge: true)
        #endif
    }

    func deleteSession(id: String, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(id).delete()
        #endif
    }
}
