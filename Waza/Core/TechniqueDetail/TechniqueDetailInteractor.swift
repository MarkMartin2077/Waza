import SwiftUI

@MainActor
protocol TechniqueDetailInteractor: GlobalInteractor {
    var allSessions: [BJJSessionModel] { get }
    func updateTechnique(_ technique: TechniqueModel) throws
    func deleteTechnique(_ technique: TechniqueModel) throws
}

extension CoreInteractor: TechniqueDetailInteractor { }
