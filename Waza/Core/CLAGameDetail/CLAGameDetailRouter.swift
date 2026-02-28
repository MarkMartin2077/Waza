import SwiftUI

struct CLAGameDetailDelegate: Equatable, Hashable {
    let gameId: String
}

@MainActor
protocol CLAGameDetailRouter: GlobalRouter { }

extension CoreRouter: CLAGameDetailRouter { }
