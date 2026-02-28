import SwiftData
import Foundation

@Model
final class TrainingGoalEntity {
    @Attribute(.unique) var goalId: String
    var title: String
    var goalDescription: String?
    var goalTypeRaw: String
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var completedDate: Date?
    var createdDate: Date

    init(
        goalId: String = UUID().uuidString,
        title: String = "",
        goalDescription: String? = nil,
        goalTypeRaw: String = "custom",
        deadline: Date? = nil,
        progress: Double = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        createdDate: Date = Date()
    ) {
        self.goalId = goalId
        self.title = title
        self.goalDescription = goalDescription
        self.goalTypeRaw = goalTypeRaw
        self.deadline = deadline
        self.progress = min(max(progress, 0), 1.0)
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.createdDate = createdDate
    }

    convenience init(from model: TrainingGoalModel) {
        self.init(
            goalId: model.goalId,
            title: model.title,
            goalDescription: model.goalDescription,
            goalTypeRaw: model.goalType.rawValue,
            deadline: model.deadline,
            progress: model.progress,
            isCompleted: model.isCompleted,
            completedDate: model.completedDate,
            createdDate: model.createdDate
        )
    }

    func toModel() -> TrainingGoalModel {
        TrainingGoalModel(
            goalId: goalId,
            title: title,
            goalDescription: goalDescription,
            goalType: GoalType(rawValue: goalTypeRaw) ?? .custom,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted,
            completedDate: completedDate,
            createdDate: createdDate
        )
    }

    func update(from model: TrainingGoalModel) {
        title = model.title
        goalDescription = model.goalDescription
        goalTypeRaw = model.goalType.rawValue
        deadline = model.deadline
        progress = min(max(model.progress, 0), 1.0)
        isCompleted = model.isCompleted
        completedDate = model.completedDate
    }
}
