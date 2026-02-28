import SwiftUI

@Observable
@MainActor
class CLAGameDetailPresenter {
    let router: any CLAGameDetailRouter
    let interactor: any CLAGameDetailInteractor
    let delegate: CLAGameDetailDelegate

    var game: CLAGameModel?
    var isShowingDiscoverySheet: Bool = false
    var discoveryText: String = ""
    var discoveryRating: Int = 3
    var isMarkingPracticed: Bool = false

    init(
        router: any CLAGameDetailRouter,
        interactor: any CLAGameDetailInteractor,
        delegate: CLAGameDetailDelegate
    ) {
        self.router = router
        self.interactor = interactor
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear(gameId: delegate.gameId))
        loadGame()
    }

    func onMarkPracticedTapped() {
        interactor.trackEvent(event: Event.markPracticed(gameId: delegate.gameId))
        try? interactor.markGamePracticed(gameId: delegate.gameId)
        loadGame()
    }

    func onLogDiscoveryTapped() {
        interactor.trackEvent(event: Event.logDiscoveryTapped)
        discoveryText = ""
        discoveryRating = 3
        isShowingDiscoverySheet = true
    }

    func onSubmitDiscovery() {
        guard !discoveryText.isEmpty else { return }
        interactor.trackEvent(event: Event.discoverySubmitted(gameId: delegate.gameId))
        _ = try? interactor.logDiscovery(
            text: discoveryText,
            successRating: discoveryRating,
            gameId: delegate.gameId,
            sessionId: nil
        )
        isShowingDiscoverySheet = false
        loadGame()
    }

    func onDeleteGameTapped() {
        guard let game else { return }
        interactor.trackEvent(event: Event.gameDeleted(gameId: delegate.gameId))
        try? interactor.deleteGame(game)
        router.dismissScreen()
    }

    private func loadGame() {
        game = interactor.claGameManager.getGame(id: delegate.gameId)
    }
}

extension CLAGameDetailPresenter {
    enum Event: LoggableEvent {
        case onAppear(gameId: String)
        case markPracticed(gameId: String)
        case logDiscoveryTapped
        case discoverySubmitted(gameId: String)
        case gameDeleted(gameId: String)

        var eventName: String {
            switch self {
            case .onAppear: return "CLAGameDetail_Appear"
            case .markPracticed: return "CLAGameDetail_MarkPracticed"
            case .logDiscoveryTapped: return "CLAGameDetail_DiscoveryTap"
            case .discoverySubmitted: return "CLAGameDetail_DiscoverySubmit"
            case .gameDeleted: return "CLAGameDetail_Delete"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(gameId: let id),
                 .markPracticed(gameId: let id),
                 .discoverySubmitted(gameId: let id),
                 .gameDeleted(gameId: let id):
                return ["game_id": id]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
