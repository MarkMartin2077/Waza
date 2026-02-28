import Foundation
import UserNotifications

@MainActor
struct ClassNotificationScheduler {

    /// Schedules a weekly recurring reminder for a class.
    func scheduleReminder(for schedule: ClassScheduleModel, gym: GymLocationModel) {
        guard schedule.reminderMinutesBefore > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Class Reminder"
        content.body = "\(schedule.name) at \(gym.name) starts in \(schedule.reminderMinutesBefore) minutes."
        content.sound = .default

        var components = DateComponents()
        components.weekday = schedule.dayOfWeek

        let totalReminderMinutes = schedule.startHour * 60 + schedule.startMinute - schedule.reminderMinutesBefore
        let clampedTotal = (totalReminderMinutes % (24 * 60) + 24 * 60) % (24 * 60)
        components.hour = clampedTotal / 60
        components.minute = clampedTotal % 60

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "waza-reminder-\(schedule.scheduleId)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    /// Cancels the reminder for a specific schedule.
    func cancelReminder(scheduleId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["waza-reminder-\(scheduleId)"]
        )
    }

    /// Cancels all Waza class reminders.
    func cancelAllReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix("waza-reminder-") }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    /// Fires an immediate "at gym" notification when geofence triggers.
    func scheduleGeofenceArrivalNotification(gym: GymLocationModel) {
        let content = UNMutableNotificationContent()
        content.title = "At \(gym.name)?"
        content.body = "You appear to be at your gym. Tap to check in!"
        content.sound = .default
        content.userInfo = ["gymId": gym.gymId]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "waza-geofence-\(gym.gymId)-\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
