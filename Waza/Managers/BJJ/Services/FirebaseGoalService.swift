import Foundation
#if !MOCK
import FirebaseFirestore
#endif

@MainActor
struct FirebaseGoalService: RemoteGoalService {
    private let collectionPath = "training_goals"

    func getGoals(userId: String) async throws -> [TrainingGoalModel] {
        #if !MOCK
        let snapshot = try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: TrainingGoalModel.self) }
        #else
        return []
        #endif
    }

    func saveGoal(_ model: TrainingGoalModel, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(model.goalId).setData(from: model, merge: true)
        #endif
    }

    func deleteGoal(id: String, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(id).delete()
        #endif
    }
}
