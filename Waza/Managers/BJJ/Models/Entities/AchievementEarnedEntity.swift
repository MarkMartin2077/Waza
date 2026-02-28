import SwiftData
import Foundation

@Model
final class AchievementEarnedEntity {
    @Attribute(.unique) var achievementEarnedId: String
    var achievementId: String
    var earnedDate: Date
    var metadata: String?

    init(
        achievementEarnedId: String = UUID().uuidString,
        achievementId: String = "",
        earnedDate: Date = Date(),
        metadata: String? = nil
    ) {
        self.achievementEarnedId = achievementEarnedId
        self.achievementId = achievementId
        self.earnedDate = earnedDate
        self.metadata = metadata
    }

    convenience init(from model: AchievementEarnedModel) {
        self.init(
            achievementEarnedId: model.achievementEarnedId,
            achievementId: model.achievementId,
            earnedDate: model.earnedDate,
            metadata: model.metadata
        )
    }

    func toModel() -> AchievementEarnedModel {
        AchievementEarnedModel(
            achievementEarnedId: achievementEarnedId,
            achievementId: achievementId,
            earnedDate: earnedDate,
            metadata: metadata
        )
    }
}
