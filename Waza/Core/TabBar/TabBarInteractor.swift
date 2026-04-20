import SwiftUI

@MainActor
protocol TabBarInteractor: GlobalInteractor {
    var gyms: [GymLocationModel] { get }
    var lastUnlockedAchievement: AchievementId? { get }
    func closestSchedule(forGymId gymId: String, at date: Date) -> ClassScheduleModel?
    func consumeUnlockedAchievement()
    var xpAppState: AppState { get }
    var pendingTechniquePromotion: TechniquePromotionData? { get }
    func clearPendingTechniquePromotion()
    func setTechniqueStage(techniqueId: String, stage: ProgressionStage) throws
}

extension CoreInteractor: TabBarInteractor {
    var pendingTechniquePromotion: TechniquePromotionData? {
        appState.pendingTechniquePromotion
    }

    func clearPendingTechniquePromotion() {
        appState.pendingTechniquePromotion = nil
    }

    func setTechniqueStage(techniqueId: String, stage: ProgressionStage) throws {
        guard let technique = techniqueManager.techniques.first(where: { $0.techniqueId == techniqueId }) else { return }
        try techniqueManager.setStage(stage, on: technique)
    }
}
