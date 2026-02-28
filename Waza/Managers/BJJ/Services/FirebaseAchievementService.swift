import FirebaseFirestore
import SwiftfulFirestore

@MainActor
struct FirebaseAchievementService: RemoteAchievementService {
    private let collectionPath = "achievements_earned"

    private func collection(for userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection(collectionPath)
    }

    func getAchievements(userId: String) async throws -> [AchievementEarnedModel] {
        try await collection(for: userId).getAllDocuments()
    }

    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws {
        try await collection(for: userId).setDocument(id: model.achievementEarnedId, document: model)
    }
}
