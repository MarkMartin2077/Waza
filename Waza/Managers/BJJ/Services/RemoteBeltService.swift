import Foundation

// MARK: - Remote Service Protocol

@MainActor
protocol RemoteBeltService: Sendable {
    func getBeltHistory(userId: String) async throws -> [BeltRecordModel]
    func saveRecord(_ model: BeltRecordModel, userId: String) async throws
    func deleteRecord(id: String, userId: String) async throws
}

// MARK: - Firebase Implementation

@MainActor
struct FirebaseBeltService: RemoteBeltService {
    private let collectionPath = "belt_history"

    func getBeltHistory(userId: String) async throws -> [BeltRecordModel] {
        // TODO: Implement using SwiftfulFirestore helpers
        return []
    }

    func saveRecord(_ model: BeltRecordModel, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
    }

    func deleteRecord(id: String, userId: String) async throws {
        // TODO: Implement using SwiftfulFirestore helpers
    }
}

// MARK: - Mock Implementation

@MainActor
final class MockRemoteBeltService: RemoteBeltService {
    var records: [BeltRecordModel] = []

    func getBeltHistory(userId: String) async throws -> [BeltRecordModel] {
        records
    }

    func saveRecord(_ model: BeltRecordModel, userId: String) async throws {
        if let index = records.firstIndex(where: { $0.beltRecordId == model.beltRecordId }) {
            records[index] = model
        } else {
            records.append(model)
        }
    }

    func deleteRecord(id: String, userId: String) async throws {
        records.removeAll { $0.beltRecordId == id }
    }
}
