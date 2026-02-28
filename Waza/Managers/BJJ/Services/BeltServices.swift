import Foundation

@MainActor
protocol BeltServices {
    var local: BeltLocalService { get }
    var remote: RemoteBeltService { get }
}

@MainActor
struct MockBeltServices: BeltServices {
    let local: BeltLocalService = SwiftDataBeltPersistence(inMemory: true)
    let remote: RemoteBeltService = MockRemoteBeltService()
}

@MainActor
struct ProductionBeltServices: BeltServices {
    let local: BeltLocalService = SwiftDataBeltPersistence()
    let remote: RemoteBeltService = FirebaseBeltService()
}
