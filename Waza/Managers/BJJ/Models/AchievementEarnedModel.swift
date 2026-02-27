import SwiftData
import Foundation

@Model
final class AchievementEarnedModel {
    @Attribute(.unique) var id: String
    var achievementId: String
    var earnedDate: Date
    var metadata: String?

    init(
        id: String = UUID().uuidString,
        achievementId: String,
        earnedDate: Date = Date(),
        metadata: String? = nil
    ) {
        self.id = id
        self.achievementId = achievementId
        self.earnedDate = earnedDate
        self.metadata = metadata
    }
}

// MARK: - Achievement Definitions

enum AchievementId: String, CaseIterable {
    case firstSession = "first_session"
    case tenSessions = "ten_sessions"
    case fiftySessions = "fifty_sessions"
    case hundredSessions = "hundred_sessions"
    case threeDayStreak = "three_day_streak"
    case sevenDayStreak = "seven_day_streak"
    case thirtyDayStreak = "thirty_day_streak"
    case firstGoalCompleted = "first_goal"
    case firstBeltPromotion = "first_belt"

    var displayName: String {
        switch self {
        case .firstSession: return "First Roll"
        case .tenSessions: return "10 Sessions"
        case .fiftySessions: return "50 Sessions"
        case .hundredSessions: return "100 Sessions"
        case .threeDayStreak: return "3-Day Streak"
        case .sevenDayStreak: return "7-Day Streak"
        case .thirtyDayStreak: return "30-Day Streak"
        case .firstGoalCompleted: return "Goal Crusher"
        case .firstBeltPromotion: return "Promoted"
        }
    }

    var achievementDescription: String {
        switch self {
        case .firstSession: return "Logged your first training session"
        case .tenSessions: return "Logged 10 training sessions"
        case .fiftySessions: return "Logged 50 training sessions"
        case .hundredSessions: return "Logged 100 training sessions"
        case .threeDayStreak: return "Trained 3 days in a row"
        case .sevenDayStreak: return "Trained 7 days in a row"
        case .thirtyDayStreak: return "Trained 30 days in a row"
        case .firstGoalCompleted: return "Completed your first goal"
        case .firstBeltPromotion: return "Recorded your first belt promotion"
        }
    }

    var iconName: String {
        switch self {
        case .firstSession: return "figure.martial.arts"
        case .tenSessions, .fiftySessions, .hundredSessions: return "number.circle.fill"
        case .threeDayStreak, .sevenDayStreak, .thirtyDayStreak: return "flame.fill"
        case .firstGoalCompleted: return "checkmark.seal.fill"
        case .firstBeltPromotion: return "star.fill"
        }
    }
}
