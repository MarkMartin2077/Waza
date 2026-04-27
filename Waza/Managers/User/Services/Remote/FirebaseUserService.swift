//
//  FirebaseUserService.swift
//  
//
//  
//
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: RemoteUserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func getUser(userId: String) async throws -> UserModel {
        try await collection.getDocument(id: userId)
    }
    
    func saveUser(user: UserModel) async throws {
        try await collection.setDocument(id: user.userId, document: user)
    }
    
    func saveUserName(userId: String, name: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedName.rawValue: name
        ])
    }
    
    func saveUserEmail(userId: String, email: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedEmail.rawValue: email
        ])
    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.fcmToken.rawValue: token
        ])
    }
    
    func saveTrainingGoal(userId: String, sessionsPerWeek: Int) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.trainingGoalPerWeek.rawValue: sessionsPerWeek
        ])
    }

    func markOnboardingCompleted(userId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.deleteDocument(id: userId)
    }
}
