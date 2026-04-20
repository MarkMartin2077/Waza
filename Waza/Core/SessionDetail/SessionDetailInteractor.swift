import SwiftUI

@MainActor
protocol SessionDetailInteractor: GlobalInteractor {
    var currentBeltEnum: BJJBelt { get }
    var allTechniques: [TechniqueModel] { get }
    func updateSession(_ session: BJJSessionModel) throws
    func deleteSession(_ session: BJJSessionModel) throws
    func createTechnique(name: String, category: TechniqueCategory)
}

extension CoreInteractor: SessionDetailInteractor { }
