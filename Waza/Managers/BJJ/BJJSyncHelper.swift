import Foundation

// MARK: - Sync Throttle

struct BJJSyncHelper {
    private static let throttleInterval: TimeInterval = 300 // 5 minutes

    static let sessionsSyncKey     = "waza.bjj.sync.sessions"
    static let beltsSyncKey        = "waza.bjj.sync.belts"
    static let goalsSyncKey        = "waza.bjj.sync.goals"
    static let achievementsSyncKey = "waza.bjj.sync.achievements"

    /// Returns true if enough time has passed since the last successful sync for this user.
    /// Scoping by userId prevents User A's throttle from blocking User B on a shared device.
    static func shouldSync(key: String, userId: String) -> Bool {
        let scopedKey = key + "." + userId
        guard let lastSync = UserDefaults.standard.object(forKey: scopedKey) as? Date else { return true }
        return Date().timeIntervalSince(lastSync) > throttleInterval
    }

    static func markSynced(key: String, userId: String) {
        UserDefaults.standard.set(Date(), forKey: key + "." + userId)
    }

    /// Call on sign-out or account deletion so the next login triggers a fresh sync.
    static func clearSyncTimestamp(key: String, userId: String) {
        UserDefaults.standard.removeObject(forKey: key + "." + userId)
    }
}

// MARK: - Sync Error Event

/// Shared LoggableEvent used by all BJJ managers to report sync failures.
struct BJJSyncErrorEvent: LoggableEvent {
    let managerName: String
    let context: String
    let error: Error

    var eventName: String { "\(managerName)_\(context)_Failed" }
    var parameters: [String: Any]? { ["error": error.localizedDescription] }
    var type: LogType { .severe }
}
