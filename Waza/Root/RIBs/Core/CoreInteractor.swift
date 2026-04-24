// swiftlint:disable file_length type_body_length
//
// CoreInteractor is intentionally long: it's the single entry point for every screen's
// Interactor protocol conformance. Keeping it in one file (rather than fragmenting across
// `+Domain.swift` extensions) is a deliberate architectural choice — see the RIBs
// core-file consolidation refactor.

import SwiftUI

@MainActor
struct CoreInteractor: GlobalInteractor {

    // MARK: - Managers (Template)

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

    // MARK: - Managers (BJJ)

    let sessionManager: SessionManager
    let beltManager: BeltManager
    let goalManager: GoalManager
    let achievementManager: AchievementManager
    let trainingStatsManager: TrainingStatsManager
    let aiInsightsManager: AIInsightsManager
    let classScheduleManager: ClassScheduleManager
    let techniqueManager: TechniqueManager
    let challengeManager: ChallengeManager

    // MARK: - Services (cross-manager orchestration)

    let accountLifecycleService: AccountLifecycleService
    let sessionLoggingService: SessionLoggingService
    let monthlyReportBuilder: MonthlyReportBuilder

    // swiftlint:disable:next function_body_length
    init(container: DependencyContainer) {
        let appState = container.resolve(AppState.self)!
        let authManager = container.resolve(AuthManager.self)!
        let userManager = container.resolve(UserManager.self)!
        let logManager = container.resolve(LogManager.self)!
        let abTestManager = container.resolve(ABTestManager.self)!
        let purchaseManager = container.resolve(PurchaseManager.self)!
        let pushManager = container.resolve(PushManager.self)!
        let hapticManager = container.resolve(HapticManager.self)!
        let soundEffectManager = container.resolve(SoundEffectManager.self)!
        let streakManager = container.resolve(StreakManager.self, key: Dependencies.streakConfiguration.streakKey)!
        let xpManager = container.resolve(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey)!
        let progressManager = container.resolve(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey)!
        let sessionManager = container.resolve(SessionManager.self)!
        let beltManager = container.resolve(BeltManager.self)!
        let goalManager = container.resolve(GoalManager.self)!
        let achievementManager = container.resolve(AchievementManager.self)!
        let trainingStatsManager = container.resolve(TrainingStatsManager.self)!
        let aiInsightsManager = container.resolve(AIInsightsManager.self)!
        let classScheduleManager = container.resolve(ClassScheduleManager.self)!
        let techniqueManager = container.resolve(TechniqueManager.self)!
        let challengeManager = container.resolve(ChallengeManager.self)!

        self.appState = appState
        self.authManager = authManager
        self.userManager = userManager
        self.logManager = logManager
        self.abTestManager = abTestManager
        self.purchaseManager = purchaseManager
        self.pushManager = pushManager
        self.hapticManager = hapticManager
        self.soundEffectManager = soundEffectManager
        self.streakManager = streakManager
        self.xpManager = xpManager
        self.progressManager = progressManager
        self.sessionManager = sessionManager
        self.beltManager = beltManager
        self.goalManager = goalManager
        self.achievementManager = achievementManager
        self.trainingStatsManager = trainingStatsManager
        self.aiInsightsManager = aiInsightsManager
        self.classScheduleManager = classScheduleManager
        self.techniqueManager = techniqueManager
        self.challengeManager = challengeManager

        self.accountLifecycleService = AccountLifecycleService(
            authManager: authManager,
            userManager: userManager,
            purchaseManager: purchaseManager,
            logManager: logManager,
            streakManager: streakManager,
            xpManager: xpManager,
            progressManager: progressManager,
            sessionManager: sessionManager,
            beltManager: beltManager,
            goalManager: goalManager,
            achievementManager: achievementManager,
            classScheduleManager: classScheduleManager,
            challengeManager: challengeManager
        )
        self.sessionLoggingService = SessionLoggingService(
            appState: appState,
            sessionManager: sessionManager,
            techniqueManager: techniqueManager,
            streakManager: streakManager,
            xpManager: xpManager,
            achievementManager: achievementManager,
            challengeManager: challengeManager,
            classScheduleManager: classScheduleManager,
            logManager: logManager,
            refreshWidgetData: { [beltManager, sessionManager, streakManager, classScheduleManager] in
                let upcoming = classScheduleManager.nextUpcomingClass
                let data = WazaWidgetData(
                    streakCount: streakManager.currentStreakData.currentStreak ?? 0,
                    accentColorHex: Color.wazaAccentHex,
                    beltDisplayName: beltManager.currentBeltEnum.displayName,
                    sessionsThisWeek: sessionManager.getSessionStats().thisWeekSessions,
                    nextClassTypeDisplayName: upcoming?.0.sessionType.displayName,
                    nextClassGymName: upcoming?.1.name,
                    nextClassDayOfWeek: upcoming?.0.dayOfWeek,
                    nextClassStartHour: upcoming?.0.startHour,
                    nextClassStartMinute: upcoming?.0.startMinute
                )
                WidgetDataStore.shared.update(data)
            }
        )
        self.monthlyReportBuilder = MonthlyReportBuilder(
            sessionManager: sessionManager,
            trainingStatsManager: trainingStatsManager,
            goalManager: goalManager,
            achievementManager: achievementManager,
            challengeManager: challengeManager,
            techniqueManager: techniqueManager,
            xpManager: xpManager
        )
    }

    // MARK: - App State

    var startingModuleId: String {
        appState.startingModuleId
    }

    var xpAppState: AppState { appState }

    // MARK: - Account Lifecycle

    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await accountLifecycleService.logIn(user: user, isNewUser: isNewUser)
    }

    func signOut() async throws {
        try await accountLifecycleService.signOut()
    }

    func deleteAccount() async throws {
        try await accountLifecycleService.deleteAccount()
    }

    // MARK: - Auth

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

    // MARK: - User

    var currentUser: UserModel? {
        userManager.currentUser
    }

    var currentUserName: String {
        currentUser?.commonNameCalculated ?? currentUser?.displayName ?? "Athlete"
    }

    func getUser(userId: String) async throws -> UserModel {
        try await userManager.getUser(userId: userId)
    }

    var hasCompletedOnboarding: Bool {
        currentUser?.didCompleteOnboarding == true
    }

    func saveOnboardingComplete() async throws {
        try await userManager.saveOnboardingCompleteForCurrentUser()
    }

    func markOnboardingComplete() async throws {
        try await userManager.saveOnboardingCompleteForCurrentUser()
    }

    func saveTrainingGoal(sessionsPerWeek: Int) async throws {
        try await userManager.saveTrainingGoal(sessionsPerWeek: sessionsPerWeek)
    }

    var trainingGoalPerWeek: Int? {
        userManager.currentUser?.trainingGoalPerWeek
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

    // MARK: - Logging / Analytics

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

    // MARK: - Push

    func requestPushAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }

    func canRequestPushAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }

    // MARK: - AB Tests

    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }

    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }

    // MARK: - Purchases

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

    // MARK: - Haptics

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

    // MARK: - Sound Effects

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

    // MARK: - Sessions

    var recentSessions: [BJJSessionModel] {
        sessionManager.getRecentSessions(limit: 5)
    }

    var allSessions: [BJJSessionModel] {
        sessionManager.sessions
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
        techniquesWorked: [String] = [],
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
            techniquesWorked: techniquesWorked,
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

    // MARK: - Belt

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
        try beltManager.addPromotion(belt: belt, stripes: stripes, date: date, academy: academy, notes: notes)
    }

    func setInitialBelt(
        belt: BJJBelt,
        stripes: Int = 0,
        date: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) throws {
        try beltManager.addPromotion(belt: belt, stripes: stripes, date: date, academy: academy, notes: notes)
        // No achievement check — this is an initial belt setup, not a promotion.
    }

    func estimatedTimeToNextBelt() -> String? {
        beltManager.estimatedTimeToNextBelt(sessionsPerWeek: Double(sessionStats.thisWeekSessions))
    }

    // MARK: - Goals

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

    @discardableResult
    func createMetricGoal(metric: GoalMetric, targetValue: Double, focusArea: String? = nil) throws -> TrainingGoalModel {
        try goalManager.createMetricGoal(metric: metric, targetValue: targetValue, focusArea: focusArea)
    }

    func computeProgress(for goal: TrainingGoalModel) -> Double {
        goalManager.computeProgress(for: goal, sessions: sessionManager.sessions)
    }

    func currentValue(for goal: TrainingGoalModel) -> Double {
        goalManager.currentValue(for: goal, sessions: sessionManager.sessions)
    }

    var distinctFocusAreas: [String] {
        Array(Set(sessionManager.sessions.flatMap { $0.focusAreas })).sorted()
    }

    // MARK: - Achievements

    var earnedAchievements: [AchievementEarnedModel] {
        achievementManager.earnedAchievements
    }

    func isAchievementEarned(_ id: AchievementId) -> Bool {
        achievementManager.isEarned(id)
    }

    var lastUnlockedAchievement: AchievementId? {
        achievementManager.lastUnlockedAchievement
    }

    func consumeUnlockedAchievement() {
        achievementManager.consumeUnlockedAchievement()
    }

    // MARK: - Techniques

    var allTechniques: [TechniqueModel] {
        techniqueManager.techniques
    }

    func updateTechnique(_ technique: TechniqueModel) throws {
        try techniqueManager.updateTechnique(technique)
    }

    func deleteTechnique(_ technique: TechniqueModel) throws {
        try techniqueManager.deleteTechnique(technique)
    }

    func createTechnique(name: String, category: TechniqueCategory) {
        _ = try? techniqueManager.createTechnique(name: name, category: category)
    }

    func ensureTechniquesExist(for focusAreas: [String]) {
        techniqueManager.ensureTechniquesExist(for: focusAreas)
    }

    // MARK: - AI Insights

    var isAIAvailable: Bool {
        aiInsightsManager.isAvailable
    }

    var aiUnavailabilityMessage: String {
        aiInsightsManager.unavailabilityMessage
    }

    func streamWeeklySummary(sessions: [BJJSessionModel], belt: BJJBelt) -> AsyncThrowingStream<String, Error> {
        aiInsightsManager.streamWeeklySummary(sessions: sessions, belt: belt)
    }

    func generateInsights(sessions: [BJJSessionModel], belt: BJJBelt) async throws -> [AITrainingInsight] {
        try await aiInsightsManager.generateInsights(sessions: sessions, belt: belt)
    }

    func generateCheckInEncouragement(context: AIEncouragementContext) -> AsyncThrowingStream<String, Error> {
        aiInsightsManager.generateCheckInEncouragement(context: context)
    }

    // MARK: - Widget

    func updateWidgetData(_ data: WazaWidgetData) {
        WidgetDataStore.shared.update(data)
    }

    /// Assemble current widget data from live managers and push it to the App Group.
    /// Call after any mutation that affects the Home Screen widgets (session save,
    /// check-in, streak freeze consumed, schedule change, gym edit).
    func refreshWidgetData() {
        let upcoming = nextUpcomingClass
        let data = WazaWidgetData(
            streakCount: currentStreakData.currentStreak ?? 0,
            accentColorHex: Color.wazaAccentHex,
            beltDisplayName: currentBeltEnum.displayName,
            sessionsThisWeek: sessionStats.thisWeekSessions,
            nextClassTypeDisplayName: upcoming?.0.sessionType.displayName,
            nextClassGymName: upcoming?.1.name,
            nextClassDayOfWeek: upcoming?.0.dayOfWeek,
            nextClassStartHour: upcoming?.0.startHour,
            nextClassStartMinute: upcoming?.0.startMinute
        )
        WidgetDataStore.shared.update(data)
    }

    // MARK: - Notifications

    func scheduleStreakRiskNotificationIfNeeded(currentStreak: Int, isAtRisk: Bool) {
        StreakRiskNotificationScheduler.scheduleIfNeeded(
            currentStreak: currentStreak,
            isAtRisk: isAtRisk
        )
    }

    // MARK: - Training Stats

    func getTrainingSnapshot(period: DateRange) -> TrainingSnapshot {
        trainingStatsManager.getTrainingSnapshot(period: period)
    }

    func getTypeBreakdown() -> [TypeStat] {
        trainingStatsManager.getTypeBreakdown()
    }

    func getTypeBreakdown(for period: DateRange) -> [TypeStat] {
        trainingStatsManager.getTypeBreakdown(for: period)
    }

    // MARK: - Monthly Report

    func getMonthlyReportData(for dateRange: DateRange) async -> MonthlyReportData {
        await monthlyReportBuilder.build(for: dateRange)
    }

    // MARK: - Streak

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

    /// Maximum freezes a user can hold at any time. Prevents indefinite stockpiling
    /// while leaving enough cushion for a travel week or minor injury.
    static let freezeCap = 3

    /// Grant a freeze if the user is under the cap. No-op if already at max.
    /// Freezes never expire — users accumulate them and spend as needed.
    @discardableResult
    func awardFreezeIfUnderCap(id: String, source: String) async -> Bool {
        let current = currentStreakData.freezesAvailableCount ?? 0
        guard current < Self.freezeCap else { return false }
        do {
            _ = try await streakManager.addStreakFreeze(id: id, dateExpires: nil)
            logManager.trackEvent(eventName: "Freeze_Awarded", parameters: ["source": source, "id": id], type: .analytic)
            return true
        } catch {
            logManager.trackEvent(
                eventName: "Freeze_AwardFailed",
                parameters: ["source": source, "id": id, "error": String(describing: error)],
                type: .severe
            )
            return false
        }
    }

    /// Grants the monthly freeze if it hasn't been awarded for the current calendar month.
    /// Safe to call on every Dashboard appear — guarded by UserDefaults.
    func awardMonthlyFreezeIfNeeded() async {
        let monthKey = Self.currentMonthKey()
        let storedKey = UserDefaults.standard.string(forKey: Self.monthlyFreezeKey)
        guard storedKey != monthKey else { return }
        let awarded = await awardFreezeIfUnderCap(id: "monthly_\(monthKey)", source: "monthly")
        // Mark the month as attempted even if we were at cap, so we don't keep trying
        // every Dashboard appear for the rest of the month.
        if awarded || (currentStreakData.freezesAvailableCount ?? 0) >= Self.freezeCap {
            UserDefaults.standard.set(monthKey, forKey: Self.monthlyFreezeKey)
        }
    }

    private static let monthlyFreezeKey = "freeze.monthly.lastGrantedMonth"

    private static func currentMonthKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
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

    // MARK: - Experience Points

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

    // MARK: - Progress

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

    // MARK: - Session Logging (Gamification Orchestration)

    func logSessionWithGamification(_ params: SessionEntryParams) async throws -> BJJSessionModel {
        try await sessionLoggingService.logSession(params: params)
    }

    func awardCheckInXP() {
        sessionLoggingService.awardCheckInXP()
    }

    func awardStreakMilestoneXP() {
        sessionLoggingService.awardStreakMilestoneXP()
    }

    // MARK: - Class Schedule

    var gyms: [GymLocationModel] {
        classScheduleManager.gyms
    }

    var schedules: [ClassScheduleModel] {
        classScheduleManager.schedules
    }

    var classAttendance: [ClassAttendanceModel] {
        classScheduleManager.attendance
    }

    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? {
        classScheduleManager.nextUpcomingClass
    }

    func closestSchedule(forGymId gymId: String, at date: Date = Date()) -> ClassScheduleModel? {
        classScheduleManager.closestSchedule(forGymId: gymId, at: date)
    }

    func weeklyAttendanceCount(weekOf date: Date = Date()) -> Int {
        classScheduleManager.weeklyAttendanceCount(weekOf: date)
    }

    @discardableResult
    func addGym(name: String, address: String? = nil, latitude: Double, longitude: Double, radius: Double = 150) throws -> GymLocationModel {
        try classScheduleManager.addGym(name: name, address: address, latitude: latitude, longitude: longitude, radius: radius)
    }

    func updateGym(_ gym: GymLocationModel) throws {
        try classScheduleManager.updateGym(gym)
    }

    func deleteGym(_ gym: GymLocationModel) throws {
        try classScheduleManager.deleteGym(gym)
    }

    @discardableResult
    func addSchedule(_ params: AddScheduleParams) throws -> ClassScheduleModel {
        try classScheduleManager.addSchedule(params)
    }

    func updateSchedule(_ schedule: ClassScheduleModel) throws {
        try classScheduleManager.updateSchedule(schedule)
    }

    func deleteSchedule(_ schedule: ClassScheduleModel) throws {
        try classScheduleManager.deleteSchedule(schedule)
    }

    func requestLocationAuthorization() {
        classScheduleManager.startGeofencing()
    }

    @discardableResult
    func checkIn(gymId: String, scheduleId: String? = nil, method: CheckInMethod = .manual, moodRating: Int? = nil) throws -> ClassAttendanceModel {
        let record = try classScheduleManager.checkIn(gymId: gymId, scheduleId: scheduleId, method: method, moodRating: moodRating)
        let totalCount = classScheduleManager.attendance.count
        let thisWeek = classScheduleManager.weeklyAttendanceCount()
        let weeklyTarget = trainingGoalPerWeek ?? 3
        let wasPerfectBefore = thisWeek - 1 >= weeklyTarget
        let isPerfectWeek = thisWeek >= weeklyTarget
        let consecutivePerfect = classScheduleManager.consecutivePerfectWeeks(weeklyTarget: weeklyTarget)
        achievementManager.checkAndAward(
            event: .classCheckedIn(totalCount: totalCount, isPerfectWeek: isPerfectWeek, consecutivePerfectWeeks: consecutivePerfect),
            sessionStats: sessionStats,
            streakCount: currentStreakData.currentStreak ?? 0
        )
        // Rating prompt only fires the week the user first hits their weekly target,
        // not on every check-in after (AppStoreRatingsHelper enforces a 60-day cooldown).
        if isPerfectWeek, !wasPerfectBefore {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                AppStoreRatingsHelper.requestReview(trigger: .perfectWeek)
            }
            // Freeze reward for hitting the weekly target — one per week, idempotent via ID.
            let weekKey = Self.weekKey(for: Date())
            Task { @MainActor in
                await awardFreezeIfUnderCap(id: "perfect_week_\(weekKey)", source: "perfect_week")
            }
        }
        return record
    }

    private static func weekKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-'W'ww"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    func updateAttendance(_ record: ClassAttendanceModel) throws {
        try classScheduleManager.updateAttendance(record)
    }

    // MARK: - Weekly Challenges

    var currentChallenges: [WeeklyChallengeModel] {
        challengeManager.currentChallenges
    }

    var completedChallengeCount: Int {
        challengeManager.completedCount
    }

    func generateChallengesIfNeeded() {
        let allFocusAreas = Set(sessionManager.sessions.flatMap(\.focusAreas))
        let recentFocusAreas = recentFocusAreasForChallenges(withinDays: 30)
        let context = ChallengeGenerator.GenerationContext(
            sessions: sessionManager.sessions,
            gyms: classScheduleManager.gyms,
            allFocusAreas: allFocusAreas,
            recentFocusAreas: recentFocusAreas,
            techniques: techniqueManager.techniques,
            weekStartDate: WeeklyChallengeModel.currentWeekStart(),
            trainingGoalPerWeek: userManager.currentUser?.trainingGoalPerWeek
        )
        // For returning users with unloaded sessions (offline / fresh install / mid-sync),
        // defer generation until the next refresh cycle so we don't lock in low-quality
        // beginner defaults. New users get immediate generation.
        challengeManager.generateIfNeeded(
            context: context,
            requireSessionData: isReturningUser
        )
    }

    /// Heuristic for distinguishing returning users from brand-new accounts.
    /// An account older than 24h with zero loaded sessions is almost certainly mid-sync,
    /// not a genuine empty history.
    private var isReturningUser: Bool {
        guard let created = userManager.currentUser?.creationDate else { return false }
        return Date().timeIntervalSince(created) > 24 * 3600
    }

    func evaluateChallenges(session: BJJSessionModel) -> [WeeklyChallengeModel] {
        let weekStart = WeeklyChallengeModel.currentWeekStart()
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }
        let weekSessions = sessionManager.sessions.filter { $0.date >= weekStart && $0.date < weekEnd }
        return challengeManager.evaluate(
            session: session,
            allSessionsThisWeek: weekSessions,
            gyms: classScheduleManager.gyms,
            techniques: techniqueManager.techniques,
            weekStart: weekStart
        )
    }

    // MARK: - Private

    private func recentFocusAreasForChallenges(withinDays days: Int) -> Set<String> {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recent = sessionManager.sessions.filter { $0.date >= cutoff }
        return Set(recent.flatMap(\.focusAreas))
    }
}
// swiftlint:enable file_length type_body_length
