import Foundation

@Observable
@MainActor
class CLAGameManager {
    private let localService: CLAGameLocalService
    private let remoteService: RemoteCLAGameService

    private(set) var games: [CLAGameModel] = []

    var builtInGames: [CLAGameModel] {
        games.filter { !$0.isCustom }
    }

    var userGames: [CLAGameModel] {
        games.filter { $0.isCustom }
    }

    init(localService: CLAGameLocalService, remoteService: RemoteCLAGameService) {
        self.localService = localService
        self.remoteService = remoteService
        refresh()
    }

    func refresh() {
        games = localService.getGames()
    }

    func getGame(id: String) -> CLAGameModel? {
        games.first { $0.gameId == id }
    }

    func getGames(for position: String) -> [CLAGameModel] {
        guard position != "All" else { return games }
        return games.filter { $0.position.lowercased() == position.lowercased() }
    }

    func getGames(for skillLevel: BeltLevel) -> [CLAGameModel] {
        guard skillLevel != .all else { return games }
        return games.filter { $0.skillLevel == skillLevel }
    }

    func getMostPracticedGames(limit: Int = 5) -> [CLAGameModel] {
        Array(games.sorted { $0.timePracticed > $1.timePracticed }.prefix(limit))
    }

    @discardableResult
    func createGame(
        name: String,
        objective: String,
        skillLevel: BeltLevel = .all,
        position: String,
        focusArea: String,
        taskConstraints: [String] = [],
        environmentConstraints: [String] = [],
        individualConstraints: [String] = [],
        expectedDiscoveries: [String] = [],
        safetyNotes: String? = nil
    ) throws -> CLAGameModel {
        let model = CLAGameModel(
            name: name,
            objective: objective,
            skillLevel: skillLevel,
            position: position,
            focusArea: focusArea,
            taskConstraints: taskConstraints,
            environmentConstraints: environmentConstraints,
            individualConstraints: individualConstraints,
            expectedDiscoveries: expectedDiscoveries,
            safetyNotes: safetyNotes,
            isCustom: true
        )
        try localService.create(model)
        refresh()
        return model
    }

    func updateGame(_ model: CLAGameModel) throws {
        try localService.update(model)
        refresh()
    }

    func deleteGame(_ model: CLAGameModel) throws {
        guard model.isCustom else { return }
        try localService.delete(id: model.gameId)
        refresh()
    }

    @discardableResult
    func logDiscovery(
        text: String,
        successRating: Int,
        gameId: String,
        sessionId: String? = nil
    ) throws -> GameDiscoveryModel {
        let discovery = GameDiscoveryModel(
            text: text,
            successRating: max(1, min(5, successRating)),
            sessionId: sessionId,
            gameId: gameId
        )
        try localService.addDiscovery(discovery, gameId: gameId)
        refresh()
        return discovery
    }

    func markPracticed(gameId: String) throws {
        try localService.incrementTimePracticed(gameId: gameId)
        refresh()
    }

    func seedBuiltInGamesIfEmpty() {
        guard builtInGames.isEmpty else { return }
        for model in CLAGameLibrary.allGames {
            try? localService.create(model)
        }
        refresh()
    }
}
