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

        // BJJ Managers
        let bjjDataManager: BJJDataManager
        let sessionManager: SessionManager
        let beltManager: BeltManager
        let goalManager: GoalManager
        let achievementManager: AchievementManager

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logger: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)

            let abTestService = MockABTestService(
                boolTest: nil,
                enumTest: nil
            )
            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService(), logger: logManager)
            appState = AppState(startingModuleId: isSignedIn ? Constants.tabbarModuleId : Constants.onboardingModuleId)
            hapticManager = HapticManager(logger: logManager)
            streakManager = StreakManager(services: MockStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: MockExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: MockProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)

            bjjDataManager = BJJDataManager(inMemory: true)
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
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                logger: logManager
            )
            hapticManager = HapticManager(logger: logManager)
            appState = AppState()
            streakManager = StreakManager(services: ProdStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: ProdExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: ProdProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)

            bjjDataManager = BJJDataManager(inMemory: false)
        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                logger: logManager
            )
            hapticManager = HapticManager(logger: logManager)
            appState = AppState()
            streakManager = StreakManager(services: ProdStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: ProdExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: ProdProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)

            bjjDataManager = BJJDataManager(inMemory: false)
        }

        pushManager = PushManager(logManager: logManager)
        soundEffectManager = SoundEffectManager(logger: logManager)

        sessionManager = SessionManager(modelContext: bjjDataManager.modelContext)
        beltManager = BeltManager(modelContext: bjjDataManager.modelContext)
        goalManager = GoalManager(modelContext: bjjDataManager.modelContext)
        achievementManager = AchievementManager(modelContext: bjjDataManager.modelContext)

        // Seed mock data for signed-in mock builds
        if case .mock(isSignedIn: let isSignedIn) = config, isSignedIn {
            sessionManager.seedMockDataIfEmpty()
            beltManager.seedMockDataIfEmpty()
            goalManager.seedMockDataIfEmpty()
        }

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
        container.register(BJJDataManager.self, service: bjjDataManager)
        container.register(SessionManager.self, service: sessionManager)
        container.register(BeltManager.self, service: beltManager)
        container.register(GoalManager.self, service: goalManager)
        container.register(AchievementManager.self, service: achievementManager)

        self.container = container

        SwiftfulRoutingLogger.enableLogging(logger: logManager)
    }

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
        container.register(BJJDataManager.self, service: bjjDataManager)
        container.register(SessionManager.self, service: sessionManager)
        container.register(BeltManager.self, service: beltManager)
        container.register(GoalManager.self, service: goalManager)
        container.register(AchievementManager.self, service: achievementManager)
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
    let bjjDataManager: BJJDataManager
    let sessionManager: SessionManager
    let beltManager: BeltManager
    let goalManager: GoalManager
    let achievementManager: AchievementManager

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
        self.bjjDataManager = BJJDataManager(inMemory: true)
        self.sessionManager = SessionManager(modelContext: bjjDataManager.modelContext)
        self.beltManager = BeltManager(modelContext: bjjDataManager.modelContext)
        self.goalManager = GoalManager(modelContext: bjjDataManager.modelContext)
        self.achievementManager = AchievementManager(modelContext: bjjDataManager.modelContext)

        if isSignedIn {
            sessionManager.seedMockDataIfEmpty()
            beltManager.seedMockDataIfEmpty()
            goalManager.seedMockDataIfEmpty()
        }
    }

}
