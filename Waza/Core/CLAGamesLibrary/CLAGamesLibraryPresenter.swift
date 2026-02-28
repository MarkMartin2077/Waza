import SwiftUI

@Observable
@MainActor
class CLAGamesLibraryPresenter {
    let router: any CLAGamesLibraryRouter
    let interactor: any CLAGamesLibraryInteractor

    var searchText: String = ""
    var selectedPosition: String = "All"
    var selectedDifficulty: BeltLevel = .all
    var isShowingCreateSheet: Bool = false

    let positions = ["All", "Guard", "Passing", "Escapes", "Submissions", "Takedowns", "Positional"]

    var filteredGames: [CLAGameModel] {
        var games = interactor.claGameManager.games

        if selectedPosition != "All" {
            games = games.filter { $0.position == selectedPosition }
        }

        if selectedDifficulty != .all {
            games = games.filter { $0.skillLevel == selectedDifficulty }
        }

        if !searchText.isEmpty {
            games = games.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.position.localizedCaseInsensitiveContains(searchText) ||
                $0.focusArea.localizedCaseInsensitiveContains(searchText)
            }
        }

        return games
    }

    init(router: any CLAGamesLibraryRouter, interactor: any CLAGamesLibraryInteractor) {
        self.router = router
        self.interactor = interactor
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onGameTapped(_ game: CLAGameModel) {
        interactor.trackEvent(event: Event.gameTapped(gameId: game.gameId))
        router.showCLAGameDetail(gameId: game.gameId)
    }

    func onCreateGameTapped() {
        interactor.trackEvent(event: Event.createGameTapped)
        isShowingCreateSheet = true
    }

    func onCreateGame(name: String, objective: String, skillLevel: BeltLevel, position: String, focusArea: String) {
        interactor.trackEvent(event: Event.createGameSubmitted)
        isShowingCreateSheet = false
        _ = try? interactor.createGame(
            name: name,
            objective: objective,
            skillLevel: skillLevel,
            position: position,
            focusArea: focusArea
        )
    }

    func onDeleteGame(_ game: CLAGameModel) {
        interactor.trackEvent(event: Event.gameDeleted(gameId: game.gameId))
        try? interactor.deleteGame(game)
    }
}

extension CLAGamesLibraryPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case gameTapped(gameId: String)
        case createGameTapped
        case createGameSubmitted
        case gameDeleted(gameId: String)

        var eventName: String {
            switch self {
            case .onAppear: return "CLAGamesLibrary_Appear"
            case .gameTapped: return "CLAGamesLibrary_GameTap"
            case .createGameTapped: return "CLAGamesLibrary_CreateTap"
            case .createGameSubmitted: return "CLAGamesLibrary_CreateSubmit"
            case .gameDeleted: return "CLAGamesLibrary_Delete"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .gameTapped(gameId: let id), .gameDeleted(gameId: let id):
                return ["game_id": id]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
