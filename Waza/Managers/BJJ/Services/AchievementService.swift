import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol AchievementLocalService {
    func getAchievements() -> [AchievementEarnedModel]
    func create(_ model: AchievementEarnedModel) throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataAchievementPersistence: AchievementLocalService {
    let container: ModelContainer

    func getAchievements() -> [AchievementEarnedModel] {
        let descriptor = FetchDescriptor<AchievementEarnedEntity>(
            sortBy: [SortDescriptor(\.earnedDate, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: AchievementEarnedModel) throws {
        let entity = AchievementEarnedEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }
}
