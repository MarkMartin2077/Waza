import Foundation
import WidgetKit
import OSLog

// MARK: - Shared Data Model
// Keep exactly in sync with WazaWidgets/WazaWidgetData.swift. Explicit CodingKeys
// ensure any drift (rename / reorder / added field on one side) surfaces as a decode
// error, not silent wrong data on the home screen.

struct WazaWidgetData: Codable {
    let streakCount: Int
    let accentColorHex: String
    let beltDisplayName: String
    let sessionsThisWeek: Int
    let nextClassTypeDisplayName: String?
    let nextClassGymName: String?
    let nextClassDayOfWeek: Int?
    let nextClassStartHour: Int?
    let nextClassStartMinute: Int?

    enum CodingKeys: String, CodingKey {
        case streakCount = "streak_count"
        case accentColorHex = "accent_color_hex"
        case beltDisplayName = "belt_display_name"
        case sessionsThisWeek = "sessions_this_week"
        case nextClassTypeDisplayName = "next_class_type_display_name"
        case nextClassGymName = "next_class_gym_name"
        case nextClassDayOfWeek = "next_class_day_of_week"
        case nextClassStartHour = "next_class_start_hour"
        case nextClassStartMinute = "next_class_start_minute"
    }
}

// MARK: - Store

@MainActor
final class WidgetDataStore {

    static let shared = WidgetDataStore()
    private init() {}

    // Must match WazaWidgets/WazaWidgetData.swift. Duplicated intentionally — the widget
    // target can't import main-app types.
    private let appGroupID = "group.com.markmartin89.Waza"
    private let dataKey = "waza_widget_data"

    private let log = OSLog(subsystem: "com.markmartin89.Waza", category: "widget")

    /// Write fresh widget state to the App Group store and reload all widget timelines.
    /// Reload fires *after* the write is flushed via `synchronize()` so widgets can't
    /// pick up the previous snapshot.
    func update(_ data: WazaWidgetData) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            os_log(.error, log: log, "App Group '%{public}@' unavailable — widget entitlement missing?", appGroupID)
            return
        }
        do {
            let encoded = try JSONEncoder().encode(data)
            defaults.set(encoded, forKey: dataKey)
            defaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            os_log(.error, log: log, "WazaWidgetData encode failed: %{public}@", String(describing: error))
        }
    }
}
