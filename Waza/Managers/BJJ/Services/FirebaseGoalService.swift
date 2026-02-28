import FirebaseFirestore
import SwiftfulFirestore

@MainActor
struct FirebaseGoalService: RemoteGoalService {
    private let collectionPath = "training_goals"

    private func collection(for userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection(collectionPath)
    }

    func getGoals(userId: String) async throws -> [TrainingGoalModel] {
        try await collection(for: userId).getAllDocuments()
    }

    func saveGoal(_ model: TrainingGoalModel, userId: String) async throws {
        try await collection(for: userId).setDocument(id: model.goalId, document: model)
    }

    func deleteGoal(id: String, userId: String) async throws {
        try await collection(for: userId).deleteDocument(id: id)
    }
}
