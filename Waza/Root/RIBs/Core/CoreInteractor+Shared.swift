import SwiftUI

extension CoreInteractor {

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

        // BJJ sync is non-blocking — each manager queues a background Task internally.
        // The app shows locally-cached data immediately; remote data merges in silently.
        sessionManager.logIn(userId: user.uid)
        beltManager.logIn(userId: user.uid)
        goalManager.logIn(userId: user.uid)
        achievementManager.logIn(userId: user.uid)

        logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)

        classScheduleManager.refresh()
        classScheduleManager.startGeofencing()
    }

    func signOut() async throws {
        // Capture before signing out — anonymous accounts can never be re-entered,
        // so we wipe local data. Named users (Apple/Google) may sign back in,
        // so we preserve their local data.
        let wasAnonymous = auth?.isAnonymous == true
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
        streakManager.logOut()
        xpManager.logOut()
        await progressManager.logOut()
        if wasAnonymous {
            clearLocalData()
        } else {
            logOutManagers()
        }
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
        clearLocalData()
    }

    // MARK: - Private

    private func clearLocalData() {
        sessionManager.clearAll()
        beltManager.clearAll()
        goalManager.clearAll()
        achievementManager.clearAll()
        classScheduleManager.clearAll()
    }

    private func logOutManagers() {
        sessionManager.logOut()
        beltManager.logOut()
        goalManager.logOut()
        achievementManager.logOut()
    }

}
