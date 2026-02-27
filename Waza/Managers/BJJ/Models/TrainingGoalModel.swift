import SwiftData
import Foundation

@Model
final class TrainingGoalModel {
    @Attribute(.unique) var id: String
    var title: String
    var goalDescription: String?
    var goalTypeRaw: String
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var completedDate: Date?
    var createdDate: Date

    var goalType: GoalType {
        get { GoalType(rawValue: goalTypeRaw) ?? .custom }
        set { goalTypeRaw = newValue.rawValue }
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    var isOverdue: Bool {
        guard let deadline, !isCompleted else { return false }
        return deadline < Date()
    }

    var daysUntilDeadline: Int? {
        guard let deadline, !isCompleted else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        goalDescription: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil,
        progress: Double = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.goalDescription = goalDescription
        self.goalTypeRaw = goalType.rawValue
        self.deadline = deadline
        self.progress = min(max(progress, 0), 1.0)
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.createdDate = createdDate
    }
}

extension TrainingGoalModel {
    static var mock: TrainingGoalModel {
        TrainingGoalModel(
            id: "mock-goal-1",
            title: "Land triangle from closed guard",
            goalDescription: "Successfully hit a triangle choke in live rolling 5 times.",
            goalType: .technique,
            deadline: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
            progress: 0.4
        )
    }

    static var mocks: [TrainingGoalModel] {
        [
            mock,
            TrainingGoalModel(
                id: "mock-goal-2",
                title: "Compete at local tournament",
                goalDescription: "Enter and compete in the next local grappling event.",
                goalType: .competition,
                deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                progress: 0.1
            ),
            TrainingGoalModel(
                id: "mock-goal-3",
                title: "Train 4x per week for a month",
                goalDescription: "Build consistent training habit.",
                goalType: .attendance,
                progress: 0.75
            )
        ]
    }
}
