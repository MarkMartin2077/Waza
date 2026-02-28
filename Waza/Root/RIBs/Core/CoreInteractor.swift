import SwiftUI

@MainActor
struct CoreInteractor: GlobalInteractor {
    let appState: AppState
    let authManager: AuthManager
    let userManager: UserManager
    let logManager: LogManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let pushManager: PushManager
    let hapticManager: HapticManager
    let soundEffectManager: SoundEffectManager
    let streakManager: StreakManager
    let xpManager: ExperiencePointsManager
    let progressManager: ProgressManager

    // MARK: BJJ Managers
    let sessionManager: SessionManager
    let beltManager: BeltManager
    let goalManager: GoalManager
    let achievementManager: AchievementManager
    let trainingStatsManager: TrainingStatsManager
    let aiInsightsManager: AIInsightsManager
    let classScheduleManager: ClassScheduleManager

    init(container: DependencyContainer) {
        self.appState = container.resolve(AppState.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.hapticManager = container.resolve(HapticManager.self)!
        self.soundEffectManager = container.resolve(SoundEffectManager.self)!
        self.streakManager = container.resolve(StreakManager.self, key: Dependencies.streakConfiguration.streakKey)!
        self.xpManager = container.resolve(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey)!
        self.progressManager = container.resolve(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey)!
        self.sessionManager = container.resolve(SessionManager.self)!
        self.beltManager = container.resolve(BeltManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
        self.achievementManager = container.resolve(AchievementManager.self)!
        self.trainingStatsManager = container.resolve(TrainingStatsManager.self)!
        self.aiInsightsManager = container.resolve(AIInsightsManager.self)!
        self.classScheduleManager = container.resolve(ClassScheduleManager.self)!
    }

}
