import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol CLAGameLocalService {
    func getGames() -> [CLAGameModel]
    func create(_ model: CLAGameModel) throws
    func update(_ model: CLAGameModel) throws
    func delete(id: String) throws
    func addDiscovery(_ discovery: GameDiscoveryModel, gameId: String) throws
    func incrementTimePracticed(gameId: String) throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataCLAGamePersistence: CLAGameLocalService {
    let container: ModelContainer

    private var context: ModelContext {
        container.mainContext
    }

    func getGames() -> [CLAGameModel] {
        let descriptor = FetchDescriptor<CLAGameEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? context.fetch(descriptor))?.map { $0.toModel() } ?? []
    }

    func create(_ model: CLAGameModel) throws {
        let entity = CLAGameEntity(from: model)
        context.insert(entity)
        try context.save()
    }

    func update(_ model: CLAGameModel) throws {
        let id = model.gameId
        let predicate = #Predicate<CLAGameEntity> { entity in
            entity.gameId == id
        }
        let descriptor = FetchDescriptor<CLAGameEntity>(predicate: predicate)
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.update(from: model)
        try context.save()
    }

    func delete(id: String) throws {
        let predicate = #Predicate<CLAGameEntity> { entity in
            entity.gameId == id
        }
        let descriptor = FetchDescriptor<CLAGameEntity>(predicate: predicate)
        guard let entity = try context.fetch(descriptor).first else { return }
        context.delete(entity)
        try context.save()
    }

    func addDiscovery(_ discovery: GameDiscoveryModel, gameId: String) throws {
        let predicate = #Predicate<CLAGameEntity> { entity in
            entity.gameId == gameId
        }
        let descriptor = FetchDescriptor<CLAGameEntity>(predicate: predicate)
        guard let game = try context.fetch(descriptor).first else { return }

        let discoveryEntity = GameDiscoveryEntity(from: discovery)
        game.discoveries.append(discoveryEntity)

        let allRatings = game.discoveries.map { Double($0.successRating) }
        game.avgSuccessRating = allRatings.isEmpty ? 0 : allRatings.reduce(0, +) / Double(allRatings.count)

        try context.save()
    }

    func incrementTimePracticed(gameId: String) throws {
        let predicate = #Predicate<CLAGameEntity> { entity in
            entity.gameId == gameId
        }
        let descriptor = FetchDescriptor<CLAGameEntity>(predicate: predicate)
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.timePracticed += 1
        try context.save()
    }
}
