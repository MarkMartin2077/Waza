//
//  MockUserService.swift
//  
//
//  
//
import SwiftUI
import UIKit

@MainActor
class MockUserService: RemoteUserService {
    
    @Published var currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getUser(userId: String) async throws -> UserModel {
        guard let user = UserModel.mocks.first(where: { $0.userId == userId }) else {
            throw URLError(.badURL)
        }
        
        return user
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        
    }
    
    func saveTrainingGoal(userId: String, sessionsPerWeek: Int) async throws {

    }

    func saveUserName(userId: String, name: String) async throws {

    }
    
    func saveUserEmail(userId: String, email: String) async throws {
        
    }
    
    func saveUserProfileImage(userId: String, image: UIImage) async throws {
        guard let user = currentUser else {
            throw URLError(.userAuthenticationRequired)
        }

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw URLError(.cannotCreateFile)
        }

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("mock_profile_\(userId)_\(UUID().uuidString).jpg")
        try data.write(to: fileURL)

        currentUser = UserModel(
            userId: user.userId,
            email: user.email,
            isAnonymous: user.isAnonymous,
            authProviders: user.authProviders,
            displayName: user.displayName,
            firstName: user.firstName,
            lastName: user.lastName,
            phoneNumber: user.phoneNumber,
            photoURL: user.photoURL,
            creationDate: user.creationDate,
            creationVersion: user.creationVersion,
            lastSignInDate: user.lastSignInDate,
            submittedEmail: user.submittedEmail,
            submittedName: user.submittedName,
            submittedProfileImage: fileURL.absoluteString,
            fcmToken: user.fcmToken,
            didCompleteOnboarding: user.didCompleteOnboarding,
            trainingGoalPerWeek: user.trainingGoalPerWeek
        )
    }
    
    func markOnboardingCompleted(userId: String) async throws {
        guard var currentUser else {
            throw URLError(.unknown)
        }
        
        currentUser.markDidCompleteOnboarding()
        self.currentUser = currentUser
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        currentUser = nil
    }
    
}
