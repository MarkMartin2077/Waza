import Foundation

@MainActor
protocol TechniqueServicesProtocol {
    var local: TechniqueLocalService { get }
    var remote: RemoteTechniqueService { get }
}

@MainActor
struct MockTechniqueServices: TechniqueServicesProtocol {
    let local: TechniqueLocalService = SwiftDataTechniquePersistence(inMemory: true)
    let remote: RemoteTechniqueService = MockRemoteTechniqueService()
}

@MainActor
struct ProductionTechniqueServices: TechniqueServicesProtocol {
    let local: TechniqueLocalService = SwiftDataTechniquePersistence()
    let remote: RemoteTechniqueService = FirebaseTechniqueService()
}
