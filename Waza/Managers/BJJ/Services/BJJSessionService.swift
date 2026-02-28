import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol BJJSessionLocalService {
    func getSessions() -> [BJJSessionModel]
    func create(_ model: BJJSessionModel) throws
    func update(_ model: BJJSessionModel) throws
    func delete(id: String) throws
    func deleteAll() throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataBJJSessionPersistence: BJJSessionLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("BJJSessions", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: BJJSessionEntity.self, configurations: config)
    }

    func getSessions() -> [BJJSessionModel] {
        let descriptor = FetchDescriptor<BJJSessionEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: BJJSessionModel) throws {
        let entity = BJJSessionEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ model: BJJSessionModel) throws {
        let idToMatch = model.sessionId
        let descriptor = FetchDescriptor<BJJSessionEntity>(
            predicate: #Predicate { $0.sessionId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: model)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<BJJSessionEntity>(
            predicate: #Predicate { $0.sessionId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: BJJSessionEntity.self)
        try container.mainContext.save()
    }
}
