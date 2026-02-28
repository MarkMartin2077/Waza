import Foundation
import IdentifiableByString
import SwiftUI

struct AchievementEarnedModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var achievementEarnedId: String
    var achievementId: String
    var earnedDate: Date
    var metadata: String?

    var id: String { achievementEarnedId }

    init(
        achievementEarnedId: String = UUID().uuidString,
        achievementId: String,
        earnedDate: Date = Date(),
        metadata: String? = nil
    ) {
        self.achievementEarnedId = achievementEarnedId
        self.achievementId = achievementId
        self.earnedDate = earnedDate
        self.metadata = metadata
    }

    init(entity: AchievementEarnedEntity) {
        self.achievementEarnedId = entity.achievementEarnedId
        self.achievementId = entity.achievementId
        self.earnedDate = entity.earnedDate
        self.metadata = entity.metadata
    }

    func toEntity() -> AchievementEarnedEntity {
        AchievementEarnedEntity(from: self)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case achievementEarnedId = "achievement_earned_id"
        case achievementId = "achievement_id"
        case earnedDate = "earned_date"
        case metadata
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "achievement_earned_id": achievementEarnedId,
            "achievement_id": achievementId
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Achievement Rarity

enum AchievementRarity {
    case common, rare, epic, legendary

    var displayName: String {
        switch self {
        case .common:    return "Common"
        case .rare:      return "Rare"
        case .epic:      return "Epic"
        case .legendary: return "Legendary"
        }
    }

    var symbolName: String {
        switch self {
        case .common:    return "circle.fill"
        case .rare:      return "star.fill"
        case .epic:      return "sparkles"
        case .legendary: return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .common:    return Color(white: 0.65)
        case .rare:      return Color(hex: "3B82F6")
        case .epic:      return Color(hex: "9333EA")
        case .legendary: return Color(hex: "F59E0B")
        }
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
    case firstClassCheckedIn = "first_class_check_in"
    case fiveClassAttendance = "five_class_attendance"
    case twentyFiveClassAttendance = "twenty_five_class_attendance"
    case perfectWeek = "perfect_week"
    case fourWeekConsistency = "four_week_streak"

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
        case .firstClassCheckedIn: return "First Check-In"
        case .fiveClassAttendance: return "Consistent"
        case .twentyFiveClassAttendance: return "Dedicated"
        case .perfectWeek: return "Perfect Week"
        case .fourWeekConsistency: return "On a Roll"
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
        case .firstClassCheckedIn: return "Checked into your first class"
        case .fiveClassAttendance: return "Attended 5 classes"
        case .twentyFiveClassAttendance: return "Attended 25 classes"
        case .perfectWeek: return "Hit your weekly training target"
        case .fourWeekConsistency: return "Hit your weekly target 4 weeks in a row"
        }
    }

    var iconName: String {
        switch self {
        case .firstSession: return "figure.wrestling"
        case .tenSessions, .fiftySessions, .hundredSessions: return "number.circle.fill"
        case .threeDayStreak, .sevenDayStreak, .thirtyDayStreak: return "flame.fill"
        case .firstGoalCompleted: return "checkmark.seal.fill"
        case .firstBeltPromotion: return "star.fill"
        case .firstClassCheckedIn: return "location.fill"
        case .fiveClassAttendance: return "checkmark.circle.fill"
        case .twentyFiveClassAttendance: return "figure.wrestling"
        case .perfectWeek: return "calendar.badge.checkmark"
        case .fourWeekConsistency: return "flame.fill"
        }
    }

    var rarity: AchievementRarity {
        switch self {
        case .firstSession:             return .common
        case .tenSessions:              return .common
        case .fiftySessions:            return .rare
        case .hundredSessions:          return .legendary
        case .threeDayStreak:           return .common
        case .sevenDayStreak:           return .rare
        case .thirtyDayStreak:          return .legendary
        case .firstGoalCompleted:       return .common
        case .firstBeltPromotion:       return .epic
        case .firstClassCheckedIn:      return .common
        case .fiveClassAttendance:      return .common
        case .twentyFiveClassAttendance: return .rare
        case .perfectWeek:              return .rare
        case .fourWeekConsistency:      return .epic
        }
    }
}
