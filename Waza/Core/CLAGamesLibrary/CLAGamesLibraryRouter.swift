import SwiftUI

@MainActor
protocol CLAGamesLibraryRouter: GlobalRouter {
    func showCLAGameDetail(gameId: String)
}

extension CoreRouter: CLAGamesLibraryRouter {
    func showCLAGameDetail(gameId: String) {
        router.showScreen(.push) { router in
            builder.claGameDetailView(router: router, delegate: CLAGameDetailDelegate(gameId: gameId))
        }
    }
}
