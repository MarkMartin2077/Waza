import Foundation

// MARK: - Challenge Type

enum ChallengeType: String, Codable, Sendable, CaseIterable {
    case trainXTimes
    case logSessionType
    case newFocusArea
    case trainAtDifferentGym
    case logMoodBothWays
    case miniStreak
    case logFullReflection
    case trainDuration
}

// MARK: - Challenge Category

enum ChallengeCategory: String, Sendable {
    case frequency    // trainXTimes, miniStreak
    case quality      // logFullReflection, logMoodBothWays
    case exploration  // newFocusArea, trainAtDifferentGym, logSessionType
    case intensity    // trainDuration
}

extension ChallengeType {
    var category: ChallengeCategory {
        switch self {
        case .trainXTimes, .miniStreak:                    return .frequency
        case .logFullReflection, .logMoodBothWays:         return .quality
        case .newFocusArea, .trainAtDifferentGym, .logSessionType: return .exploration
        case .trainDuration:                               return .intensity
        }
    }
}

// MARK: - Weekly Challenge Model

struct WeeklyChallengeModel: Codable, Sendable, Identifiable {
    var challengeId: String
    var weekStartDate: Date
    var challengeType: ChallengeType
    var title: String
    var targetValue: Int
    var currentValue: Int
    var isCompleted: Bool
    var completedDate: Date?
    var metadata: String?

    var id: String { challengeId }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    var progressText: String { "\(currentValue)/\(targetValue)" }

    init(
        challengeId: String = UUID().uuidString,
        weekStartDate: Date,
        challengeType: ChallengeType,
        title: String,
        targetValue: Int,
        currentValue: Int = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        metadata: String? = nil
    ) {
        self.challengeId = challengeId
        self.weekStartDate = weekStartDate
        self.challengeType = challengeType
        self.title = title
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.metadata = metadata
    }

    // MARK: - Entity Bridge

    init(from entity: WeeklyChallengeEntity) {
        self.challengeId = entity.challengeId
        self.weekStartDate = entity.weekStartDate
        self.challengeType = ChallengeType(rawValue: entity.challengeTypeRaw) ?? .trainXTimes
        self.title = entity.title
        self.targetValue = entity.targetValue
        self.currentValue = entity.currentValue
        self.isCompleted = entity.isCompleted
        self.completedDate = entity.completedDate
        self.metadata = entity.metadata
    }

    func toEntity() -> WeeklyChallengeEntity {
        WeeklyChallengeEntity(from: self)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case challengeId = "challenge_id"
        case weekStartDate = "week_start_date"
        case challengeType = "challenge_type"
        case title
        case targetValue = "target_value"
        case currentValue = "current_value"
        case isCompleted = "is_completed"
        case completedDate = "completed_date"
        case metadata
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "challenge_id": challengeId,
            "challenge_type": challengeType.rawValue,
            "target_value": targetValue,
            "current_value": currentValue,
            "is_completed": isCompleted
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Week Start Date

extension WeeklyChallengeModel {
    /// Returns the Monday 00:00 local time for the current week.
    static func currentWeekStart() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components) ?? now
    }
}

// MARK: - Mock Data

extension WeeklyChallengeModel {
    static var mocks: [WeeklyChallengeModel] {
        let weekStart = currentWeekStart()
        return [
            WeeklyChallengeModel(
                challengeId: "mock-challenge-1",
                weekStartDate: weekStart,
                challengeType: .trainXTimes,
                title: "Train 3 times this week",
                targetValue: 3,
                currentValue: 3,
                isCompleted: true,
                completedDate: Calendar.current.date(byAdding: .day, value: 2, to: weekStart)
            ),
            WeeklyChallengeModel(
                challengeId: "mock-challenge-2",
                weekStartDate: weekStart,
                challengeType: .logFullReflection,
                title: "Write a full session reflection",
                targetValue: 1,
                currentValue: 0,
                isCompleted: false
            ),
            WeeklyChallengeModel(
                challengeId: "mock-challenge-3",
                weekStartDate: weekStart,
                challengeType: .logMoodBothWays,
                title: "Rate your mood before & after a session",
                targetValue: 1,
                currentValue: 1,
                isCompleted: true,
                completedDate: Calendar.current.date(byAdding: .day, value: 1, to: weekStart)
            )
        ]
    }
}
