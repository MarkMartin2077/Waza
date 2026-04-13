import SwiftUI

@MainActor
protocol TechniqueJournalRouter: GlobalRouter {
    func showTechniqueDetailView(technique: TechniqueModel)
}

extension CoreRouter: TechniqueJournalRouter { }
