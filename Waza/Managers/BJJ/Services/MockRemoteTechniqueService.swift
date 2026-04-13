import Foundation

@MainActor
final class MockRemoteTechniqueService: RemoteTechniqueService {
    var techniques: [TechniqueModel]

    init(techniques: [TechniqueModel] = []) {
        self.techniques = techniques
    }

    func getTechniques(userId: String, limit: Int) async throws -> [TechniqueModel] {
        techniques
    }

    func saveTechnique(_ technique: TechniqueModel, userId: String) async throws {
        if let index = techniques.firstIndex(where: { $0.techniqueId == technique.techniqueId }) {
            techniques[index] = technique
        } else {
            techniques.append(technique)
        }
    }

    func deleteTechnique(id: String, userId: String) async throws {
        techniques.removeAll { $0.techniqueId == id }
    }
}
