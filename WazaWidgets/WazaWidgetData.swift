import SwiftUI
import OSLog

extension OSLog {
    static let widget = OSLog(subsystem: "com.markmartin89.Waza", category: "widget")
}

// MARK: - Shared data model
// Intentionally duplicated from Waza/Utilities/WidgetDataStore.swift.
// Both targets encode/decode the same JSON from App Group UserDefaults.

/// App Group ID shared between the Waza app and WazaWidgets extension.
/// Must match the entitlements file on both targets.
enum WazaWidgetConstants {
    static let appGroupID = "group.com.markmartin89.Waza"
    static let dataKey = "waza_widget_data"
}

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

    // Explicit keys ensure the encoded shape is stable and drift between app ⇄ widget
    // surfaces as a compile error, not a silent decode failure. Keep this exactly in sync
    // with Waza/Utilities/WidgetDataStore.swift.
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

    static var placeholder: WazaWidgetData {
        WazaWidgetData(
            streakCount: 7,
            accentColorHex: "6366F1",
            beltDisplayName: "Blue Belt",
            sessionsThisWeek: 3,
            nextClassTypeDisplayName: "Gi",
            nextClassGymName: "Gracie Barra",
            nextClassDayOfWeek: 2,
            nextClassStartHour: 19,
            nextClassStartMinute: 0
        )
    }

    static func load() -> WazaWidgetData {
        guard
            let defaults = UserDefaults(suiteName: WazaWidgetConstants.appGroupID),
            let data = defaults.data(forKey: WazaWidgetConstants.dataKey)
        else {
            return .placeholder
        }
        do {
            return try JSONDecoder().decode(WazaWidgetData.self, from: data)
        } catch {
            // Decode failures fall back to placeholder; OSLog for TestFlight diagnosis.
            os_log(.error, log: .widget, "WazaWidgetData decode failed: %{public}@", String(describing: error))
            return .placeholder
        }
    }

    var accentColor: Color {
        Color(hex: accentColorHex)
    }

    var nextClassTimeString: String? {
        guard let dayOfWeek = nextClassDayOfWeek,
              let startHour = nextClassStartHour,
              let startMinute = nextClassStartMinute
        else { return nil }

        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let dayName = (dayOfWeek >= 1 && dayOfWeek <= 7) ? dayNames[dayOfWeek - 1] : "—"
        let isPM = startHour >= 12
        let displayHour = startHour == 0 ? 12 : (startHour > 12 ? startHour - 12 : startHour)
        let minuteStr = String(format: "%02d", startMinute)
        return "\(dayName) \(displayHour):\(minuteStr) \(isPM ? "PM" : "AM")"
    }
}

// MARK: - Color from hex (widget-local, mirrors Color+EXT.swift)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue: UInt64
        switch hex.count {
        case 6:
            (red, green, blue) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255
        )
    }
}
