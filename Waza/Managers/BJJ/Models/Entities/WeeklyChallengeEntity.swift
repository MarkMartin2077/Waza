import SwiftData
import Foundation

@Model
final class WeeklyChallengeEntity {
    @Attribute(.unique) var challengeId: String
    var weekStartDate: Date
    var challengeTypeRaw: String
    var title: String
    var targetValue: Int
    var currentValue: Int
    var isCompleted: Bool
    var completedDate: Date?
    var metadata: String?

    init(
        challengeId: String = UUID().uuidString,
        weekStartDate: Date = Date(),
        challengeTypeRaw: String = ChallengeType.trainXTimes.rawValue,
        title: String = "",
        targetValue: Int = 1,
        currentValue: Int = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        metadata: String? = nil
    ) {
        self.challengeId = challengeId
        self.weekStartDate = weekStartDate
        self.challengeTypeRaw = challengeTypeRaw
        self.title = title
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.metadata = metadata
    }

    convenience init(from model: WeeklyChallengeModel) {
        self.init(
            challengeId: model.challengeId,
            weekStartDate: model.weekStartDate,
            challengeTypeRaw: model.challengeType.rawValue,
            title: model.title,
            targetValue: model.targetValue,
            currentValue: model.currentValue,
            isCompleted: model.isCompleted,
            completedDate: model.completedDate,
            metadata: model.metadata
        )
    }

    func toModel() -> WeeklyChallengeModel {
        WeeklyChallengeModel(from: self)
    }

    func update(from model: WeeklyChallengeModel) {
        challengeTypeRaw = model.challengeType.rawValue
        title = model.title
        targetValue = model.targetValue
        currentValue = model.currentValue
        isCompleted = model.isCompleted
        completedDate = model.completedDate
        metadata = model.metadata
    }
}
