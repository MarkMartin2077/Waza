import Foundation

@MainActor
protocol RemoteBeltService: Sendable {
    func getBeltHistory(userId: String) async throws -> [BeltRecordModel]
    func saveRecord(_ model: BeltRecordModel, userId: String) async throws
    func deleteRecord(id: String, userId: String) async throws
}
