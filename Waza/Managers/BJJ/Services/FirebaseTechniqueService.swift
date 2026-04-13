import FirebaseFirestore
import SwiftfulFirestore

@MainActor
struct FirebaseTechniqueService: RemoteTechniqueService {
    private let collectionPath = "bjj_techniques"

    private func collection(for userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection(collectionPath)
    }

    func getTechniques(userId: String, limit: Int) async throws -> [TechniqueModel] {
        try await collection(for: userId).getAllDocuments()
    }

    func saveTechnique(_ technique: TechniqueModel, userId: String) async throws {
        try await collection(for: userId).setDocument(id: technique.techniqueId, document: technique)
    }

    func deleteTechnique(id: String, userId: String) async throws {
        try await collection(for: userId).deleteDocument(id: id)
    }
}
