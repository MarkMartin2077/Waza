import Foundation

struct TrainingGoalModel: Codable, Sendable, Identifiable {
    var goalId: String
    var title: String
    var goalDescription: String?
    var goalType: GoalType
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var completedDate: Date?
    var createdDate: Date

    var id: String { goalId }

    init(
        goalId: String = UUID().uuidString,
        title: String,
        goalDescription: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil,
        progress: Double = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        createdDate: Date = Date()
    ) {
        self.goalId = goalId
        self.title = title
        self.goalDescription = goalDescription
        self.goalType = goalType
        self.deadline = deadline
        self.progress = min(max(progress, 0), 1.0)
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.createdDate = createdDate
    }

    init(entity: TrainingGoalEntity) {
        self.goalId = entity.goalId
        self.title = entity.title
        self.goalDescription = entity.goalDescription
        self.goalType = GoalType(rawValue: entity.goalTypeRaw) ?? .custom
        self.deadline = entity.deadline
        self.progress = entity.progress
        self.isCompleted = entity.isCompleted
        self.completedDate = entity.completedDate
        self.createdDate = entity.createdDate
    }

    func toEntity() -> TrainingGoalEntity {
        TrainingGoalEntity(from: self)
    }

    // MARK: - Computed Display Properties

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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case goalId = "goal_id"
        case title
        case goalDescription = "goal_description"
        case goalType = "goal_type"
        case deadline
        case progress
        case isCompleted = "is_completed"
        case completedDate = "completed_date"
        case createdDate = "created_date"
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "goal_id": goalId,
            "goal_type": goalType.rawValue,
            "is_completed": isCompleted,
            "progress": progress
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension TrainingGoalModel {
    static var mock: TrainingGoalModel {
        TrainingGoalModel(
            goalId: "mock-goal-1",
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
                goalId: "mock-goal-2",
                title: "Compete at local tournament",
                goalDescription: "Enter and compete in the next local grappling event.",
                goalType: .competition,
                deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                progress: 0.1
            ),
            TrainingGoalModel(
                goalId: "mock-goal-3",
                title: "Train 4x per week for a month",
                goalDescription: "Build consistent training habit.",
                goalType: .attendance,
                progress: 0.75
            )
        ]
    }
}
