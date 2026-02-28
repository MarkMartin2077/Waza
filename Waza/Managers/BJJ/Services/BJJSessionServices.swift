import Foundation

@MainActor
protocol BJJSessionServices {
    var local: BJJSessionLocalService { get }
    var remote: RemoteBJJSessionService { get }
}

@MainActor
struct MockBJJSessionServices: BJJSessionServices {
    let local: BJJSessionLocalService = SwiftDataBJJSessionPersistence(inMemory: true)
    let remote: RemoteBJJSessionService = MockRemoteBJJSessionService()
}

@MainActor
struct ProductionBJJSessionServices: BJJSessionServices {
    let local: BJJSessionLocalService = SwiftDataBJJSessionPersistence()
    let remote: RemoteBJJSessionService = FirebaseBJJSessionService()
}
