import SwiftUI

@MainActor
struct CoreInteractor: GlobalInteractor {
    private let appState: AppState
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    private let pushManager: PushManager
    private let hapticManager: HapticManager
    private let soundEffectManager: SoundEffectManager
    private let streakManager: StreakManager
    private let xpManager: ExperiencePointsManager
    private let progressManager: ProgressManager

    // MARK: BJJ Managers
    let sessionManager: SessionManager
    let beltManager: BeltManager
    let goalManager: GoalManager
    let achievementManager: AchievementManager
    let claGameManager: CLAGameManager
    let trainingStatsManager: TrainingStatsManager

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
        self.claGameManager = container.resolve(CLAGameManager.self)!
        self.trainingStatsManager = container.resolve(TrainingStatsManager.self)!
    }

    // MARK: APP STATE

    var startingModuleId: String {
        appState.startingModuleId
    }

    // MARK: AuthManager

    var auth: UserAuthInfo? {
        authManager.auth
    }

    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }

    func signInGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        guard let clientId = Constants.firebaseAppClientId else {
            throw AppError("Firebase not configured or clientID missing")
        }
        return try await authManager.signInGoogle(GIDClientID: clientId)
    }

    // MARK: UserManager

    var currentUser: UserModel? {
        userManager.currentUser
    }

    func getUser(userId: String) async throws -> UserModel {
        try await userManager.getUser(userId: userId)
    }

    func saveOnboardingComplete() async throws {
        try await userManager.saveOnboardingCompleteForCurrentUser()
    }

    func saveUserName(name: String) async throws {
        try await userManager.saveUserName(name: name)
    }

    func saveUserEmail(email: String) async throws {
        try await userManager.saveUserEmail(email: email)
    }

    func saveUserProfileImage(image: UIImage) async throws {
        try await userManager.saveUserProfileImage(image: image)
    }

    func saveUserFCMToken(token: String) async throws {
        try await userManager.saveUserFCMToken(token: token)
    }

    // MARK: LogManager

    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }

    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }

    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }

    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    // MARK: PushManager

    func requestPushAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }

    func canRequestPushAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }

    // MARK: ABTestManager

    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }

    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }

    // MARK: PurchaseManager

    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }

    var isPremium: Bool {
        entitlements.hasActiveEntitlement
    }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }

    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }

    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }

    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }

    // MARK: Haptics

    func prepareHaptic(option: HapticOption) {
        hapticManager.prepare(option: option)
    }

    func prepareHaptics(options: [HapticOption]) {
        hapticManager.prepare(options: options)
    }

    func playHaptic(option: HapticOption) {
        hapticManager.play(option: option)
    }

    func playHaptics(options: [HapticOption]) {
        hapticManager.play(options: options)
    }

    func tearDownHaptic(option: HapticOption) {
        hapticManager.tearDown(option: option)
    }

    func tearDownHaptics(options: [HapticOption]) {
        hapticManager.tearDown(options: options)
    }

    func tearDownAllHaptics() {
        hapticManager.tearDownAll()
    }

    // MARK: Sound Effects

    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int = 1) {
        Task {
            await soundEffectManager.prepare(url: sound.url, simultaneousPlayers: simultaneousPlayers, volume: 1)
        }
    }

    func tearDownSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.tearDown(url: sound.url)
        }
    }

    func playSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.play(url: sound.url)
        }
    }

    // MARK: StreakManager

    var currentStreakData: CurrentStreakData {
        streakManager.currentStreakData
    }

    @discardableResult
    func addStreakEvent(metadata: [String: GamificationDictionaryValue] = [:]) async throws -> StreakEvent {
        try await streakManager.addStreakEvent(metadata: metadata)
    }

    func getAllStreakEvents() async throws -> [StreakEvent] {
        try await streakManager.getAllStreakEvents()
    }

    func deleteAllStreakEvents() async throws {
        try await streakManager.deleteAllStreakEvents()
    }

    @discardableResult
    func addStreakFreeze(id: String, dateExpires: Date? = nil) async throws -> StreakFreeze {
        try await streakManager.addStreakFreeze(id: id, dateExpires: dateExpires)
    }

    func useStreakFreezes() async throws {
        try await streakManager.useStreakFreezes()
    }

    func getAllStreakFreezes() async throws -> [StreakFreeze] {
        try await streakManager.getAllStreakFreezes()
    }

    func recalculateStreak() {
        streakManager.recalculateStreak()
    }

    // MARK: ExperiencePointsManager

    var currentExperiencePointsData: CurrentExperiencePointsData {
        xpManager.currentExperiencePointsData
    }

    @discardableResult
    func addExperiencePoints(points: Int, metadata: [String: GamificationDictionaryValue] = [:]) async throws -> ExperiencePointsEvent {
        try await xpManager.addExperiencePoints(points: points, metadata: metadata)
    }

    func getAllExperiencePointsEvents() async throws -> [ExperiencePointsEvent] {
        try await xpManager.getAllExperiencePointsEvents()
    }

    func getAllExperiencePointsEvents(forField field: String, equalTo value: GamificationDictionaryValue) async throws -> [ExperiencePointsEvent] {
        try await xpManager.getAllExperiencePointsEvents(forField: field, equalTo: value)
    }

    func deleteAllExperiencePointsEvents() async throws {
        try await xpManager.deleteAllExperiencePointsEvents()
    }

    func recalculateExperiencePoints() {
        xpManager.recalculateExperiencePoints()
    }

    // MARK: ProgressManager

    func getProgress(id: String) -> Double {
        progressManager.getProgress(id: id)
    }

    func getProgressItem(id: String) -> ProgressItem? {
        progressManager.getProgressItem(id: id)
    }

    func getAllProgress() -> [String: Double] {
        progressManager.getAllProgress()
    }

    func getAllProgressItems() -> [ProgressItem] {
        progressManager.getAllProgressItems()
    }

    func getProgressItems(forMetadataField metadataField: String, equalTo value: GamificationDictionaryValue) -> [ProgressItem] {
        progressManager.getProgressItems(forMetadataField: metadataField, equalTo: value)
    }

    func getMaxProgress(forMetadataField metadataField: String, equalTo value: GamificationDictionaryValue) -> Double {
        progressManager.getMaxProgress(forMetadataField: metadataField, equalTo: value)
    }

    @discardableResult
    func addProgress(id: String, value: Double, metadata: [String: GamificationDictionaryValue]? = nil) async throws -> ProgressItem {
        try await progressManager.addProgress(id: id, value: value, metadata: metadata)
    }

    func deleteProgress(id: String) async throws {
        try await progressManager.deleteProgress(id: id)
    }

    func deleteAllProgress() async throws {
        try await progressManager.deleteAllProgress()
    }

    // MARK: BJJ Sessions

    var recentSessions: [BJJSessionModel] {
        sessionManager.getRecentSessions(limit: 5)
    }

    var sessionStats: SessionStats {
        sessionManager.getSessionStats()
    }

    @discardableResult
    func createSession(
        date: Date = Date(),
        duration: TimeInterval = 5400,
        sessionType: SessionType = .gi,
        academy: String? = nil,
        instructor: String? = nil,
        focusAreas: [String] = [],
        notes: String? = nil,
        preSessionMood: Int? = nil,
        postSessionMood: Int? = nil,
        roundsCount: Int = 0,
        whatWorkedWell: String? = nil,
        needsImprovement: String? = nil,
        keyInsights: String? = nil
    ) throws -> BJJSessionModel {
        try sessionManager.createSession(
            date: date,
            duration: duration,
            sessionType: sessionType,
            academy: academy,
            instructor: instructor,
            focusAreas: focusAreas,
            notes: notes,
            preSessionMood: preSessionMood,
            postSessionMood: postSessionMood,
            roundsCount: roundsCount,
            whatWorkedWell: whatWorkedWell,
            needsImprovement: needsImprovement,
            keyInsights: keyInsights
        )
    }

    func updateSession(_ session: BJJSessionModel) throws {
        try sessionManager.updateSession(session)
    }

    func deleteSession(_ session: BJJSessionModel) throws {
        try sessionManager.deleteSession(session)
    }

    // MARK: BJJ Belt

    var currentBelt: BeltRecordModel? {
        beltManager.currentBelt
    }

    var currentBeltEnum: BJJBelt {
        beltManager.currentBeltEnum
    }

    var beltHistory: [BeltRecordModel] {
        beltManager.beltHistory
    }

    @discardableResult
    func addBeltPromotion(
        belt: BJJBelt,
        stripes: Int = 0,
        date: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) throws -> BeltRecordModel {
        let record = try beltManager.addPromotion(belt: belt, stripes: stripes, date: date, academy: academy, notes: notes)
        achievementManager.checkAndAward(
            event: .beltPromoted(belt: belt),
            sessionStats: sessionStats,
            streakCount: currentStreakData.currentStreak ?? 0
        )
        return record
    }

    func estimatedTimeToNextBelt() -> String? {
        beltManager.estimatedTimeToNextBelt(sessionsPerWeek: Double(sessionStats.thisWeekSessions))
    }

    // MARK: BJJ Goals

    var activeGoals: [TrainingGoalModel] {
        goalManager.activeGoals
    }

    var completedGoals: [TrainingGoalModel] {
        goalManager.completedGoals
    }

    @discardableResult
    func createGoal(
        title: String,
        description: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil
    ) throws -> TrainingGoalModel {
        try goalManager.createGoal(title: title, description: description, goalType: goalType, deadline: deadline)
    }

    func updateGoalProgress(goalId: String, progress: Double) throws {
        try goalManager.updateProgress(goalId: goalId, progress: progress)
    }

    func completeGoal(goalId: String) throws {
        try goalManager.completeGoal(goalId: goalId)
        achievementManager.checkAndAward(
            event: .goalCompleted(goalId: goalId),
            sessionStats: sessionStats,
            streakCount: currentStreakData.currentStreak ?? 0
        )
    }

    func updateGoal(_ goal: TrainingGoalModel) throws {
        try goalManager.updateGoal(goal)
    }

    func deleteGoal(_ goal: TrainingGoalModel) throws {
        try goalManager.deleteGoal(goal)
    }

    // MARK: BJJ Achievements

    var earnedAchievements: [AchievementEarnedModel] {
        achievementManager.earnedAchievements
    }

    func isAchievementEarned(_ id: AchievementId) -> Bool {
        achievementManager.isEarned(id)
    }

    // MARK: CLA Games

    var allGames: [CLAGameModel] {
        claGameManager.games
    }

    var builtInGames: [CLAGameModel] {
        claGameManager.builtInGames
    }

    var userGames: [CLAGameModel] {
        claGameManager.userGames
    }

    func getGame(id: String) -> CLAGameModel? {
        claGameManager.getGame(id: id)
    }

    func getGames(for position: String) -> [CLAGameModel] {
        claGameManager.getGames(for: position)
    }

    @discardableResult
    func createGame(
        name: String,
        objective: String,
        skillLevel: BeltLevel = .all,
        position: String,
        focusArea: String,
        taskConstraints: [String] = [],
        environmentConstraints: [String] = [],
        individualConstraints: [String] = [],
        expectedDiscoveries: [String] = [],
        safetyNotes: String? = nil
    ) throws -> CLAGameModel {
        try claGameManager.createGame(
            name: name,
            objective: objective,
            skillLevel: skillLevel,
            position: position,
            focusArea: focusArea,
            taskConstraints: taskConstraints,
            environmentConstraints: environmentConstraints,
            individualConstraints: individualConstraints,
            expectedDiscoveries: expectedDiscoveries,
            safetyNotes: safetyNotes
        )
    }

    func deleteGame(_ game: CLAGameModel) throws {
        try claGameManager.deleteGame(game)
    }

    @discardableResult
    func logDiscovery(text: String, successRating: Int, gameId: String, sessionId: String? = nil) throws -> GameDiscoveryModel {
        try claGameManager.logDiscovery(text: text, successRating: successRating, gameId: gameId, sessionId: sessionId)
    }

    func markGamePracticed(gameId: String) throws {
        try claGameManager.markPracticed(gameId: gameId)
    }

    func getMostPracticedGames(limit: Int = 5) -> [CLAGameModel] {
        claGameManager.getMostPracticedGames(limit: limit)
    }

    // MARK: Training Stats

    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot {
        trainingStatsManager.getTrainingSnapshot(period: period)
    }

    func getCLAStatSummary() -> CLAStatSummary {
        trainingStatsManager.getCLAStatSummary()
    }

    func getTypeBreakdown() -> [TypeStat] {
        trainingStatsManager.getTypeBreakdown()
    }

    func getTypeBreakdown(for period: DateRange) -> [TypeStat] {
        trainingStatsManager.getTypeBreakdown(for: period)
    }

    // MARK: Session + Gamification Combined

    func logSessionWithGamification(_ params: SessionEntryParams) async throws -> BJJSessionModel {
        let session = try createSession(
            date: params.date,
            duration: params.duration,
            sessionType: params.sessionType,
            academy: params.academy,
            instructor: params.instructor,
            focusAreas: params.focusAreas,
            notes: params.notes,
            preSessionMood: params.preSessionMood,
            postSessionMood: params.postSessionMood,
            roundsCount: params.roundsCount,
            whatWorkedWell: params.whatWorkedWell,
            needsImprovement: params.needsImprovement,
            keyInsights: params.keyInsights
        )

        async let streakResult = addStreakEvent()
        async let xpResult = addExperiencePoints(points: 10)
        _ = try await (streakResult, xpResult)

        let stats = sessionStats
        achievementManager.checkAndAward(
            event: .sessionLogged(totalCount: stats.totalSessions, streakCount: currentStreakData.currentStreak ?? 0),
            sessionStats: stats,
            streakCount: currentStreakData.currentStreak ?? 0
        )

        return session
    }

    // MARK: SHARED

    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        async let userLogin: Void = userManager.logIn(auth: user, isNewUser: isNewUser)
        async let purchaseLogin: ([PurchasedEntitlement]) = purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctId,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
        async let streakLogin: Void = streakManager.logIn(userId: user.uid)
        async let xpLogin: Void = xpManager.logIn(userId: user.uid)
        async let progressLogin: Void = progressManager.logIn(userId: user.uid)

        let (_, _, _, _, _) = await (try userLogin, try purchaseLogin, try streakLogin, try xpLogin, try progressLogin)

        logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
    }

    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
        streakManager.logOut()
        xpManager.logOut()
        await progressManager.logOut()
    }

    func deleteAccount() async throws {
        guard let auth else {
            throw AppError("Auth not found.")
        }

        var option: SignInOption = .anonymous
        if auth.authProviders.contains(.apple) {
            option = .apple
        } else if auth.authProviders.contains(.google), let clientId = Constants.firebaseAppClientId {
            option = .google(GIDClientID: clientId)
        }

        try await authManager.deleteAccountWithReauthentication(option: option, revokeToken: false) {
            try await userManager.deleteCurrentUser()
        }

        try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }

}
