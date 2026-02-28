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

        logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)

        classScheduleManager.refresh()
        classScheduleManager.startGeofencing()
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
