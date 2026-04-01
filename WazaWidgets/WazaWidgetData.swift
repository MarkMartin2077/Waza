import SwiftUI

// MARK: - Shared data model
// Intentionally duplicated from Waza/Utilities/WidgetDataStore.swift.
// Both targets encode/decode the same JSON from App Group UserDefaults.

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
            let data = UserDefaults(suiteName: "group.com.markmartin89.Waza")?.data(forKey: "waza_widget_data"),
            let decoded = try? JSONDecoder().decode(WazaWidgetData.self, from: data)
        else {
            return .placeholder
        }
        return decoded
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
