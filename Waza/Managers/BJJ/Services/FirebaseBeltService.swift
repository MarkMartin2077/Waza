import FirebaseFirestore
import SwiftfulFirestore

@MainActor
struct FirebaseBeltService: RemoteBeltService {
    private let collectionPath = "belt_history"

    private func collection(for userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection(collectionPath)
    }

    func getBeltHistory(userId: String) async throws -> [BeltRecordModel] {
        try await collection(for: userId).getAllDocuments()
    }

    func saveRecord(_ model: BeltRecordModel, userId: String) async throws {
        try await collection(for: userId).setDocument(id: model.beltRecordId, document: model)
    }

    func deleteRecord(id: String, userId: String) async throws {
        try await collection(for: userId).deleteDocument(id: id)
    }
}
