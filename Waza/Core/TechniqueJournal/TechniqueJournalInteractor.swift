import SwiftUI

@MainActor
protocol TechniqueJournalInteractor: GlobalInteractor {
    var allTechniques: [TechniqueModel] { get }
    var allSessions: [BJJSessionModel] { get }
    func createTechnique(name: String, category: TechniqueCategory)
    func ensureTechniquesExist(for focusAreas: [String])
}

extension CoreInteractor: TechniqueJournalInteractor { }
