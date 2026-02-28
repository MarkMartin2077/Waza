import Foundation
#if !MOCK
import FirebaseFirestore
#endif

@MainActor
struct FirebaseAchievementService: RemoteAchievementService {
    private let collectionPath = "achievements_earned"

    func getAchievements(userId: String) async throws -> [AchievementEarnedModel] {
        #if !MOCK
        let snapshot = try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: AchievementEarnedModel.self) }
        #else
        return []
        #endif
    }

    func saveAchievement(_ model: AchievementEarnedModel, userId: String) async throws {
        #if !MOCK
        try await Firestore.firestore()
            .collection("users").document(userId).collection(collectionPath)
            .document(model.achievementEarnedId).setData(from: model, merge: true)
        #endif
    }
}
