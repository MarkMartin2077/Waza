import StoreKit
import UIKit

enum RatingPromptTrigger: String {
    case settingsManualRequest
    case sessionMilestone
    case streakMilestone
    case weeklyChallengeSweep
    case perfectWeek

    /// Manual requests honor the user's explicit tap and bypass cooldown;
    /// automatic triggers respect a 60-day cooldown so we don't over-prompt.
    var isAutomatic: Bool {
        self != .settingsManualRequest
    }
}

@MainActor
enum AppStoreRatingsHelper {

    // MARK: - Public API

    /// Attempt to surface the native in-app review prompt.
    /// - Returns: `true` if Apple's `requestReview` was invoked. Apple may still silently
    ///   throttle the actual prompt — caller should still offer `openAppStoreReviewURL()`
    ///   as a fallback for manual requests if nothing visible happens.
    @discardableResult
    static func requestReview(trigger: RatingPromptTrigger) -> Bool {
        if trigger.isAutomatic {
            // Global cooldown for auto-triggers so positive moments in the same week don't stack.
            let elapsedDays = Calendar.current.dateComponents(
                [.day],
                from: Date(timeIntervalSince1970: lastPromptEpoch),
                to: Date()
            ).day ?? .max
            guard elapsedDays >= 60 else { return false }
        }

        guard let scene = activeWindowScene() else { return false }

        AppStore.requestReview(in: scene)
        lastPromptEpoch = Date().timeIntervalSince1970
        hasPrompted = true
        return true
    }

    /// Guaranteed fallback when `requestReview` can't or won't surface (Apple throttled,
    /// user already reviewed, scene unavailable). Opens the App Store review page directly.
    static func openAppStoreReviewURL() {
        let urlString = "https://apps.apple.com/app/id\(appStoreAppId)?action=write-review"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Storage

    @UserDefault(key: "ratings.lastPromptEpoch", startingValue: 0.0)
    private static var lastPromptEpoch: Double

    @UserDefault(key: "ratings.hasPrompted", startingValue: false)
    private static var hasPrompted: Bool

    // MARK: - Private

    private static let appStoreAppId = "6759821384"

    private static func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
