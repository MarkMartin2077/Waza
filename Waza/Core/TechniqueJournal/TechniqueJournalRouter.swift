import SwiftUI

@MainActor
protocol TechniqueJournalRouter: GlobalRouter {
    func showTechniqueDetailView(technique: TechniqueModel)
    func showAddTechniqueView(onSave: @escaping @MainActor @Sendable (String, TechniqueCategory) -> Void)
}

extension CoreRouter: TechniqueJournalRouter { }
