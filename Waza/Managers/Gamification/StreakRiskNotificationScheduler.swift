import Foundation
import UserNotifications

@MainActor
enum StreakRiskNotificationScheduler {

    private static let notificationId = "waza-streak-risk"

    /// Schedule a daily evening reminder to train if streak is at risk.
    /// Called after each session log or on app launch.
    static func scheduleIfNeeded(currentStreak: Int, isAtRisk: Bool) {
        let center = UNUserNotificationCenter.current()

        // Always cancel the old one first
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])

        // Only schedule if there's a streak worth protecting
        guard currentStreak >= 2, !isAtRisk else { return }

        // Schedule for 8 PM today — "you haven't trained yet today"
        let content = UNMutableNotificationContent()
        content.title = "Streak at risk!"
        let tier = StreakTier.tier(forDays: currentStreak)
        if tier != .none {
            content.body = "Your \(currentStreak)-day streak (\(tier.displayName) +\(tier.bonusPercent)% XP) needs a session today."
        } else {
            content.body = "Your \(currentStreak)-day streak needs a session today. Don't let it slip!"
        }
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        center.add(request)
    }

    /// Cancel any pending streak risk notification (e.g., after logging a session today).
    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationId]
        )
    }
}
