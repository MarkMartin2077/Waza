//
//  WelcomeInteractor.swift
//  
//
//  
//

@MainActor
protocol WelcomeInteractor: GlobalInteractor {
    var hasCompletedOnboarding: Bool { get }
    var auth: UserAuthInfo? { get }
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: WelcomeInteractor { }
