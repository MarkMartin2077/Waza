import Foundation

struct CalendarDelegate: Equatable, Hashable {
    var eventParameters: [String: Any]? { nil }

    static func == (lhs: CalendarDelegate, rhs: CalendarDelegate) -> Bool { true }
    func hash(into hasher: inout Hasher) {}
}
