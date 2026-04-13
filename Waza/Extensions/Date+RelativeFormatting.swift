import Foundation

extension Date {

    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let fullShortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    /// Returns a relative date string: "Today", "Yesterday", day name, or "MMM d".
    var relativeFormatted: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "Today" }
        if calendar.isDateInYesterday(self) { return "Yesterday" }
        let daysAgo = calendar.dateComponents([.day], from: self, to: Date()).day ?? 0
        if daysAgo < 7 {
            return Self.dayOfWeekFormatter.string(from: self)
        }
        return Self.shortDateFormatter.string(from: self)
    }

    /// Returns "MMM d, yyyy" formatted string.
    var shortFormatted: String {
        Self.fullShortDateFormatter.string(from: self)
    }
}
