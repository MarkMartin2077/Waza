//
//  Constants.swift
//  Waza
//
//  
//
struct Constants {
    static let randomImage = "https://picsum.photos/600/600"
    static let privacyPolicyUrlString = "https://boatneck-pickle-bfa.notion.site/Waza-Privacy-Policy-33517d63a01a8043ab9cf6a2dd88e654"
    static let termsOfServiceUrlString = "https://boatneck-pickle-bfa.notion.site/Waza-Terms-of-Service-33517d63a01a8084bdc8db91fd02100a"
    static let supportUrlString = "https://boatneck-pickle-bfa.notion.site/Waza-Support-33517d63a01a80f3ab13db26f36726d0"
    
    static let onboardingModuleId = "onboarding"
    static let tabbarModuleId = "tabbar"
    
    static let streakKey = "daily" // daily streaks
    static let xpKey = "general" // general XP
    static let progressKey = "general" // general progress

    static let colorSchemeStorageKey = "waza_colorSchemeIndex"

    static var mixpanelDistinctId: String? {
        #if MOCK
        return nil
        #else
        return MixpanelService.distinctId
        #endif
    }
    
    static var firebaseAnalyticsAppInstanceID: String? {
        #if MOCK
        return nil
        #else
        return FirebaseAnalyticsService.appInstanceID
        #endif
    }

    @MainActor
    static var firebaseAppClientId: String? {
        #if MOCK
        return nil
        #else
        return FirebaseAuthService.clientId
        #endif
    }

}
