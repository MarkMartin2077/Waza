import Foundation

// MARK: - Remote Protocol

@MainActor
protocol RemoteCLAGameService: Sendable {
    func getGames(userId: String) async throws -> [CLAGameModel]
    func saveGame(_ model: CLAGameModel, userId: String) async throws
    func deleteGame(id: String, userId: String) async throws
}

// MARK: - Firebase (stub)

struct FirebaseCLAGameService: RemoteCLAGameService {
    func getGames(userId: String) async throws -> [CLAGameModel] {
        // TODO: Firebase sync
        return []
    }

    func saveGame(_ model: CLAGameModel, userId: String) async throws {
        // TODO: Firebase sync
    }

    func deleteGame(id: String, userId: String) async throws {
        // TODO: Firebase sync
    }
}

// MARK: - Mock

final class MockRemoteCLAGameService: RemoteCLAGameService, @unchecked Sendable {
    func getGames(userId: String) async throws -> [CLAGameModel] { [] }
    func saveGame(_ model: CLAGameModel, userId: String) async throws { }
    func deleteGame(id: String, userId: String) async throws { }
}
