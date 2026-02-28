import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol AchievementLocalService {
    func getAchievements() -> [AchievementEarnedModel]
    func create(_ model: AchievementEarnedModel) throws
    func deleteAll() throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataAchievementPersistence: AchievementLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("Achievements", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AchievementEarnedEntity.self, configurations: config)
    }

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

    func deleteAll() throws {
        try container.mainContext.delete(model: AchievementEarnedEntity.self)
        try container.mainContext.save()
    }
}
