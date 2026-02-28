import Foundation
#if !MOCK
import FirebaseFirestore
#endif

@MainActor
struct FirebaseBeltService: RemoteBeltService {
    private let collectionPath = "belt_history"

    func getBeltHistory(userId: String) async throws -> [BeltRecordModel] {
        #if !MOCK
        let snapshot = try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: BeltRecordModel.self) }
        #else
        return []
        #endif
    }

    func saveRecord(_ model: BeltRecordModel, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(model.beltRecordId).setData(from: model, merge: true)
        #endif
    }

    func deleteRecord(id: String, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(id).delete()
        #endif
    }
}
