import SwiftUI

extension CoreInteractor {

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

}
