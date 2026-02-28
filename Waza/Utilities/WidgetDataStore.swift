import Foundation
import WidgetKit

// MARK: - Shared Data Model
// This struct is intentionally duplicated in WazaWidgets/WazaWidgetData.swift.
// Both targets encode/decode to the same JSON format via App Group UserDefaults.

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
}

// MARK: - Store

@MainActor
final class WidgetDataStore {

    static let shared = WidgetDataStore()
    private init() {}

    private let appGroupID = "group.com.markmartin89.Waza"
    private let dataKey = "waza_widget_data"

    func update(_ data: WazaWidgetData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        UserDefaults(suiteName: appGroupID)?.set(encoded, forKey: dataKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
