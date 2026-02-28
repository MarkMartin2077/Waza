import Foundation

// MARK: - Session Type

enum SessionType: String, Codable, CaseIterable {
    case gi
    case noGi = "no_gi"
    case openMat = "open_mat"
    case competition
    case drilling
    case privateLesson = "private"

    var displayName: String {
        switch self {
        case .gi: return "Gi"
        case .noGi: return "No-Gi"
        case .openMat: return "Open Mat"
        case .competition: return "Competition"
        case .drilling: return "Drilling"
        case .privateLesson: return "Private Lesson"
        }
    }

    var iconName: String {
        switch self {
        case .gi: return "figure.martial.arts"
        case .noGi: return "figure.wrestling"
        case .openMat: return "circle.grid.2x2.fill"
        case .competition: return "trophy.fill"
        case .drilling: return "repeat.circle.fill"
        case .privateLesson: return "person.fill.checkmark"
        }
    }
}

// MARK: - BJJ Belt

enum BJJBelt: String, Codable, CaseIterable {
    case white
    case blue
    case purple
    case brown
    case black

    var displayName: String { rawValue.capitalized }

    var order: Int {
        switch self {
        case .white: return 0
        case .blue: return 1
        case .purple: return 2
        case .brown: return 3
        case .black: return 4
        }
    }

    var nextBelt: BJJBelt? {
        switch self {
        case .white: return .blue
        case .blue: return .purple
        case .purple: return .brown
        case .brown: return .black
        case .black: return nil
        }
    }

    var typicalYearsToNext: Double? {
        switch self {
        case .white: return 2.0
        case .blue: return 3.0
        case .purple: return 3.5
        case .brown: return 2.5
        case .black: return nil
        }
    }

    var colorHex: String {
        switch self {
        case .white: return "F5F5F5"
        case .blue: return "1E56A0"
        case .purple: return "7B2D8B"
        case .brown: return "795548"
        case .black: return "1A1A1A"
        }
    }
}

// MARK: - Goal Type

enum GoalType: String, Codable, CaseIterable {
    case technique
    case competition
    case fitness
    case beltPromotion = "belt_promotion"
    case attendance
    case custom

    var displayName: String {
        switch self {
        case .technique: return "Technique"
        case .competition: return "Competition"
        case .fitness: return "Fitness"
        case .beltPromotion: return "Belt Promotion"
        case .attendance: return "Attendance"
        case .custom: return "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .technique: return "figure.martial.arts"
        case .competition: return "trophy.fill"
        case .fitness: return "heart.fill"
        case .beltPromotion: return "star.fill"
        case .attendance: return "calendar.circle.fill"
        case .custom: return "target"
        }
    }
}

// MARK: - Injury Severity

enum InjurySeverity: String, Codable, CaseIterable {
    case minor
    case moderate
    case severe

    var displayName: String { rawValue.capitalized }
}

// MARK: - Progression Stage

enum ProgressionStage: String, Codable, CaseIterable {
    case learning
    case drilling
    case applying
    case polishing

    var displayName: String { rawValue.capitalized }

    var order: Int {
        switch self {
        case .learning: return 0
        case .drilling: return 1
        case .applying: return 2
        case .polishing: return 3
        }
    }
}

// MARK: - Check-In Method

enum CheckInMethod: String, Codable, CaseIterable {
    case geofence
    case manual

    var displayName: String {
        switch self {
        case .geofence: return "Auto Check-In"
        case .manual: return "Manual"
        }
    }

    var iconName: String {
        switch self {
        case .geofence: return "location.fill"
        case .manual: return "hand.tap.fill"
        }
    }
}

// MARK: - Achievement Event

enum AchievementEvent {
    case sessionLogged(totalCount: Int, streakCount: Int)
    case streakReached(count: Int)
    case goalCompleted(goalId: String)
    case beltPromoted(belt: BJJBelt)
    case xpMilestone(points: Int)
    case classCheckedIn(totalCount: Int, isPerfectWeek: Bool, consecutivePerfectWeeks: Int)
}

// MARK: - Stats

struct SessionStats {
    let totalSessions: Int
    let totalTrainingTime: TimeInterval
    let averageSessionDuration: TimeInterval
    let thisWeekSessions: Int
    let thisMonthSessions: Int

    var totalTrainingHours: Double {
        totalTrainingTime / 3600
    }

    var averageSessionMinutes: Int {
        Int(averageSessionDuration / 60)
    }

    static let empty = SessionStats(
        totalSessions: 0,
        totalTrainingTime: 0,
        averageSessionDuration: 0,
        thisWeekSessions: 0,
        thisMonthSessions: 0
    )
}

// MARK: - Training Stat Types

struct TypeStat {
    let sessionType: SessionType
    let count: Int
    let percentage: Double
}

struct DayCount {
    let date: Date
    let count: Int
}

struct TrainingSnapshot {
    let period: DateRange
    let sessionCount: Int
    let totalHours: Double
    let avgDurationMinutes: Int
    let typeBreakdown: [TypeStat]
    let sessionFrequency: [DayCount]

    static let empty = TrainingSnapshot(
        period: .lastMonth,
        sessionCount: 0,
        totalHours: 0,
        avgDurationMinutes: 0,
        typeBreakdown: [],
        sessionFrequency: []
    )
}

// MARK: - Date Range

struct DateRange {
    let start: Date
    let end: Date

    static func lastDays(_ days: Int) -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -days, to: end) ?? end
        return DateRange(start: start, end: end)
    }

    static var lastWeek: DateRange { lastDays(7) }
    static var lastMonth: DateRange { lastDays(30) }
    static var lastYear: DateRange { lastDays(365) }
    static var allTime: DateRange {
        DateRange(start: Date(timeIntervalSince1970: 0), end: Date())
    }
}
