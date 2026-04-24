//
//  WelcomeBackInteractor.swift
//  Waza
//

@MainActor
protocol WelcomeBackInteractor: GlobalInteractor {
    var currentUserName: String { get }
}

extension CoreInteractor: WelcomeBackInteractor { }
