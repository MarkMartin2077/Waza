import Foundation

@MainActor
protocol RemoteTechniqueService: Sendable {
    func getTechniques(userId: String, limit: Int) async throws -> [TechniqueModel]
    func saveTechnique(_ technique: TechniqueModel, userId: String) async throws
    func deleteTechnique(id: String, userId: String) async throws
}
