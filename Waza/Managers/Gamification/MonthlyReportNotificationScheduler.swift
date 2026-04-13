import Foundation
import UserNotifications

@MainActor
enum MonthlyReportNotificationScheduler {

    private static let notificationId = "waza-monthly-report"

    /// Schedule a notification for the 1st of next month at 9 AM to announce the monthly report.
    /// Called on each app launch so the month name is always current.
    static func scheduleIfNeeded() {
        let center = UNUserNotificationCenter.current()

        // Always cancel and reschedule so the month label stays accurate
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])

        let content = UNMutableNotificationContent()
        let previousMonthName = previousMonthName()
        content.title = "Your \(previousMonthName) training report is ready"
        content.body = "See your stats, streaks, and highlights from last month."
        content.sound = .default

        // Fire on the 1st of next month at 9 AM
        var components = DateComponents()
        components.day = 1
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        center.add(request)
    }

    /// Cancel any pending monthly report notification.
    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationId]
        )
    }

    // MARK: - Private

    /// Returns the name of the current month (which will be the "previous month" when the
    /// notification fires on the 1st of next month).
    private static func previousMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
}
