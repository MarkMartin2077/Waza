//
//  Dependencies.swift
//  Waza
//
//
import SwiftUI
import SwiftfulRouting

@MainActor
struct Dependencies {
    let container: DependencyContainer

    static let streakConfiguration = StreakConfiguration(
        streakKey: Constants.streakKey,
        eventsRequiredPerDay: 1,
        useServerCalculation: false,
        leewayHours: 0,
        freezeBehavior: .autoConsumeFreezes
    )

    static let xpConfiguration = ExperiencePointsConfiguration(
        experienceKey: Constants.xpKey,
        useServerCalculation: false
    )

    static let progressConfiguration = ProgressConfiguration(
        progressKey: Constants.progressKey
    )

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
        let authManager: AuthManager
        let userManager: UserManager
        let abTestManager: ABTestManager
        let purchaseManager: PurchaseManager
        let appState: AppState
        let logManager: LogManager
        let pushManager: PushManager
        let hapticManager: HapticManager
        let soundEffectManager: SoundEffectManager
        let streakManager: StreakManager
        let xpManager: ExperiencePointsManager
        let progressManager: ProgressManager
        let sessionManager: SessionManager
        let beltManager: BeltManager
        let goalManager: GoalManager
        let achievementManager: AchievementManager
        let trainingStatsManager: TrainingStatsManager
        let aiInsightsManager: AIInsightsManager
        let classScheduleManager: ClassScheduleManager

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logger: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            abTestManager = ABTestManager(service: MockABTestService(boolTest: nil, enumTest: nil), logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService(), logger: logManager)
            appState = AppState(startingModuleId: isSignedIn ? Constants.tabbarModuleId : Constants.onboardingModuleId)
            hapticManager = HapticManager(logger: logManager)
            streakManager = StreakManager(services: MockStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: MockExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: MockProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)

            sessionManager = SessionManager(services: MockBJJSessionServices())
            beltManager = BeltManager(services: MockBeltServices())
            goalManager = GoalManager(services: MockGoalServices())
            achievementManager = AchievementManager(services: MockAchievementServices())
            trainingStatsManager = TrainingStatsManager(sessionManager: sessionManager)
            aiInsightsManager = AIInsightsManager()
            classScheduleManager = ClassScheduleManager(services: MockClassScheduleServices())

            if isSignedIn {
                sessionManager.seedMockDataIfEmpty()
                beltManager.seedMockDataIfEmpty()
                goalManager.seedMockDataIfEmpty()
                classScheduleManager.seedMockDataIfEmpty()
            }

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(service: StoreKitPurchaseService(), logger: logManager)
            hapticManager = HapticManager(logger: logManager)
            appState = AppState()
            streakManager = StreakManager(services: ProdStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: ProdExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: ProdProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)

            sessionManager = SessionManager(services: ProductionBJJSessionServices())
            beltManager = BeltManager(services: ProductionBeltServices())
            goalManager = GoalManager(services: ProductionGoalServices())
            achievementManager = AchievementManager(services: ProductionAchievementServices())
            trainingStatsManager = TrainingStatsManager(sessionManager: sessionManager)
            aiInsightsManager = AIInsightsManager()
            classScheduleManager = ClassScheduleManager(services: ProductionClassScheduleServices())

        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey), logger: logManager)
            hapticManager = HapticManager(logger: logManager)
            appState = AppState()
            streakManager = StreakManager(services: ProdStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: ProdExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: ProdProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)

            sessionManager = SessionManager(services: ProductionBJJSessionServices())
            beltManager = BeltManager(services: ProductionBeltServices())
            goalManager = GoalManager(services: ProductionGoalServices())
            achievementManager = AchievementManager(services: ProductionAchievementServices())
            trainingStatsManager = TrainingStatsManager(sessionManager: sessionManager)
            aiInsightsManager = AIInsightsManager()
            classScheduleManager = ClassScheduleManager(services: ProductionClassScheduleServices())
        }

        pushManager = PushManager(logManager: logManager)
        soundEffectManager = SoundEffectManager(logger: logManager)

        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        container.register(PushManager.self, service: pushManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)
        container.register(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey, service: xpManager)
        container.register(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey, service: progressManager)
        container.register(SessionManager.self, service: sessionManager)
        container.register(BeltManager.self, service: beltManager)
        container.register(GoalManager.self, service: goalManager)
        container.register(AchievementManager.self, service: achievementManager)
        container.register(TrainingStatsManager.self, service: trainingStatsManager)
        container.register(AIInsightsManager.self, service: aiInsightsManager)
        container.register(ClassScheduleManager.self, service: classScheduleManager)

        self.container = container

        SwiftfulRoutingLogger.enableLogging(logger: logManager)
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()

    func container() -> DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        container.register(PushManager.self, service: pushManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)
        container.register(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey, service: xpManager)
        container.register(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey, service: progressManager)
        container.register(SessionManager.self, service: sessionManager)
        container.register(BeltManager.self, service: beltManager)
        container.register(GoalManager.self, service: goalManager)
        container.register(AchievementManager.self, service: achievementManager)
        container.register(TrainingStatsManager.self, service: trainingStatsManager)
        container.register(AIInsightsManager.self, service: aiInsightsManager)
        container.register(ClassScheduleManager.self, service: classScheduleManager)
        return container
    }

    let authManager: AuthManager
    let userManager: UserManager
    let logManager: LogManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let appState: AppState
    let pushManager: PushManager
    let hapticManager: HapticManager
    let soundEffectManager: SoundEffectManager
    let streakManager: StreakManager
    let xpManager: ExperiencePointsManager
    let progressManager: ProgressManager
    let sessionManager: SessionManager
    let beltManager: BeltManager
    let goalManager: GoalManager
    let achievementManager: AchievementManager
    let trainingStatsManager: TrainingStatsManager
    let aiInsightsManager: AIInsightsManager
    let classScheduleManager: ClassScheduleManager

    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.logManager = LogManager(services: [])
        self.abTestManager = ABTestManager(service: MockABTestService())
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
        self.appState = AppState()
        self.pushManager = PushManager()
        self.hapticManager = HapticManager()
        self.soundEffectManager = SoundEffectManager()
        self.streakManager = StreakManager(services: MockStreakServices(), configuration: StreakConfiguration.mockDefault())
        self.xpManager = ExperiencePointsManager(services: MockExperiencePointsServices(), configuration: ExperiencePointsConfiguration.mockDefault())
        self.progressManager = ProgressManager(services: MockProgressServices(), configuration: ProgressConfiguration.mockDefault())
        self.sessionManager = SessionManager(services: MockBJJSessionServices())
        self.beltManager = BeltManager(services: MockBeltServices())
        self.goalManager = GoalManager(services: MockGoalServices())
        self.achievementManager = AchievementManager(services: MockAchievementServices())
        self.trainingStatsManager = TrainingStatsManager(sessionManager: sessionManager)
        self.aiInsightsManager = AIInsightsManager()
        self.classScheduleManager = ClassScheduleManager(services: MockClassScheduleServices())

        if isSignedIn {
            sessionManager.seedMockDataIfEmpty()
            beltManager.seedMockDataIfEmpty()
            goalManager.seedMockDataIfEmpty()
            classScheduleManager.seedMockDataIfEmpty()
        }
    }
}
