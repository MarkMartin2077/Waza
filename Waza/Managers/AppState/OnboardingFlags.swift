import Foundation

/// UserDefaults-backed flags tracking which one-time onboarding tips the user has seen.
/// Each flag is cheap to read — no manager dependency, no Firestore round-trip.
@MainActor
enum OnboardingFlags {

    private enum Keys {
        static let hasSeenChallengesTip = "onboarding.hasSeenChallengesTip"
        static let lastDismissedMonthlyReportKey = "onboarding.lastDismissedMonthlyReportKey"
        static let hasSeenReorganizationNudge = "onboarding.hasSeenReorganizationNudge"
    }

    // MARK: - Challenge Tip

    static var hasSeenChallengesTip: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasSeenChallengesTip) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasSeenChallengesTip) }
    }

    // MARK: - Tab Reorganization Nudge
    //
    // One-time nudge on Home after the v1.x → v2.0 IA reshuffle. Points users at the
    // new Train and Progress tabs so they can find features that moved.

    static var hasSeenReorganizationNudge: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasSeenReorganizationNudge) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasSeenReorganizationNudge) }
    }

    // MARK: - Monthly Report Banner
    //
    // Stored as "YYYY-MM" of the most recently dismissed banner. The banner re-appears
    // at the start of each new month because the stored key no longer matches.

    static var lastDismissedMonthlyReportKey: String {
        get { UserDefaults.standard.string(forKey: Keys.lastDismissedMonthlyReportKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastDismissedMonthlyReportKey) }
    }

    /// Monthly report banner should show during the first 7 days of a month
    /// and when the user hasn't already dismissed this month's banner.
    static func shouldShowMonthlyReportBanner(now: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: now)
        guard day <= 7 else { return false }
        return lastDismissedMonthlyReportKey != monthKey(for: now)
    }

    static func dismissMonthlyReportBanner(now: Date = Date()) {
        lastDismissedMonthlyReportKey = monthKey(for: now)
    }

    private static func monthKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
