import SwiftUI

@MainActor
protocol CLAGamesLibraryInteractor: GlobalInteractor {
    var claGameManager: CLAGameManager { get }
    func createGame(
        name: String,
        objective: String,
        skillLevel: BeltLevel,
        position: String,
        focusArea: String
    ) throws -> CLAGameModel
    func deleteGame(_ game: CLAGameModel) throws
}

extension CoreInteractor: CLAGamesLibraryInteractor {
    func createGame(
        name: String,
        objective: String,
        skillLevel: BeltLevel,
        position: String,
        focusArea: String
    ) throws -> CLAGameModel {
        try claGameManager.createGame(
            name: name,
            objective: objective,
            skillLevel: skillLevel,
            position: position,
            focusArea: focusArea
        )
    }
}
