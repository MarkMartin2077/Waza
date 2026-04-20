//
//  AppState.swift
//  Waza
//
//  
//
import SwiftUI
import SwiftfulRouting

@MainActor
@Observable
class AppState {
    
    let startingModuleId: String

    /// Transient signal for the XP gain toast. Set after awarding XP, consumed by TabBar.
    var lastXPGain: XPToastData?

    /// Transient signal for fire round activation modal.
    var pendingFireRoundActivation: Bool = false

    /// Transient signal for streak tier-up modal (new tier).
    var pendingStreakTierUp: StreakTier?

    /// Transient signal for weekly challenge completion toast. Title of the completed challenge.
    /// Consumed by TabBar to surface a toast to the user.
    var pendingChallengeCompletion: String?

    /// Transient signal for technique stage promotion prompt.
    /// Set after a session is logged, consumed by TabBar to surface the prompt sheet.
    var pendingTechniquePromotion: TechniquePromotionData?

    init(startingModuleId: String = UserDefaults.lastModuleId) {
        self.startingModuleId = startingModuleId
    }

}

// MARK: - Technique Promotion Data

struct TechniquePromotionData: Identifiable, Equatable, Sendable {
    var id: String { techniqueId }
    let techniqueId: String
    let techniqueName: String
    let currentStage: String
    let suggestedStage: String
    let practiceCount: Int
}

// MARK: - XP Toast Data

struct XPToastData: Equatable, Sendable {
    let totalPoints: Int
    let leveledUp: Bool
    let newLevel: Int?
    let newTitle: String?
    let breakdownText: String?
    let multiplierText: String?
    let isFireRound: Bool
}
