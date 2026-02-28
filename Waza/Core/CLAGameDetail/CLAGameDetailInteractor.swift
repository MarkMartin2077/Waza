import SwiftUI

@MainActor
protocol CLAGameDetailInteractor: GlobalInteractor {
    var claGameManager: CLAGameManager { get }
    func markGamePracticed(gameId: String) throws
    func logDiscovery(text: String, successRating: Int, gameId: String, sessionId: String?) throws -> GameDiscoveryModel
    func deleteGame(_ game: CLAGameModel) throws
}

extension CoreInteractor: CLAGameDetailInteractor { }
