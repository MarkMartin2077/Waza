import SwiftUI

@MainActor
protocol TechniqueDetailRouter: GlobalRouter {
    func showSessionDetailView(session: BJJSessionModel)
}

extension CoreRouter: TechniqueDetailRouter { }
