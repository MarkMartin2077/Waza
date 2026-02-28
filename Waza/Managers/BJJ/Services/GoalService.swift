import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol GoalLocalService {
    func getGoals() -> [TrainingGoalModel]
    func create(_ model: TrainingGoalModel) throws
    func update(_ model: TrainingGoalModel) throws
    func delete(id: String) throws
    func deleteAll() throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataGoalPersistence: GoalLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("TrainingGoals", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: TrainingGoalEntity.self, configurations: config)
    }

    func getGoals() -> [TrainingGoalModel] {
        let descriptor = FetchDescriptor<TrainingGoalEntity>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: TrainingGoalModel) throws {
        let entity = TrainingGoalEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ model: TrainingGoalModel) throws {
        let idToMatch = model.goalId
        let descriptor = FetchDescriptor<TrainingGoalEntity>(
            predicate: #Predicate { $0.goalId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: model)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<TrainingGoalEntity>(
            predicate: #Predicate { $0.goalId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: TrainingGoalEntity.self)
        try container.mainContext.save()
    }
}
