import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol TechniqueLocalService {
    func getTechniques() -> [TechniqueModel]
    func create(_ technique: TechniqueModel) throws
    func update(_ technique: TechniqueModel) throws
    func delete(id: String) throws
    func deleteAll() throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataTechniquePersistence: TechniqueLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("Techniques", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: TechniqueEntity.self, configurations: config)
    }

    func getTechniques() -> [TechniqueModel] {
        let descriptor = FetchDescriptor<TechniqueEntity>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ technique: TechniqueModel) throws {
        let entity = TechniqueEntity(from: technique)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ technique: TechniqueModel) throws {
        let idToMatch = technique.techniqueId
        let descriptor = FetchDescriptor<TechniqueEntity>(
            predicate: #Predicate { $0.techniqueId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: technique)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<TechniqueEntity>(
            predicate: #Predicate { $0.techniqueId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: TechniqueEntity.self)
        try container.mainContext.save()
    }
}
