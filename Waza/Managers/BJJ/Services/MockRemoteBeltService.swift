import Foundation

@MainActor
final class MockRemoteBeltService: RemoteBeltService {
    var records: [BeltRecordModel]

    init(records: [BeltRecordModel] = []) {
        self.records = records
    }

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
