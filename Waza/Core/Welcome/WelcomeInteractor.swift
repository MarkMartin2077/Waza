//
//  WelcomeInteractor.swift
//  
//
//  
//

@MainActor
protocol WelcomeInteractor: GlobalInteractor {
    var hasCompletedOnboarding: Bool { get }
}

extension CoreInteractor: WelcomeInteractor { }
