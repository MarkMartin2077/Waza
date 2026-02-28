import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol BeltLocalService {
    func getBeltHistory() -> [BeltRecordModel]
    func create(_ model: BeltRecordModel) throws
    func delete(id: String) throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataBeltPersistence: BeltLocalService {
    let container: ModelContainer

    func getBeltHistory() -> [BeltRecordModel] {
        let descriptor = FetchDescriptor<BeltRecordEntity>(
            sortBy: [SortDescriptor(\.promotionDate, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ model: BeltRecordModel) throws {
        let entity = BeltRecordEntity(from: model)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<BeltRecordEntity>(
            predicate: #Predicate { $0.beltRecordId == id }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        container.mainContext.delete(entity)
        try container.mainContext.save()
    }
}
