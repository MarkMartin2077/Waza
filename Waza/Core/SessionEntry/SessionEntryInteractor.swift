import SwiftUI

struct SessionEntryParams {
    let date: Date
    let duration: TimeInterval
    let sessionType: SessionType
    let academy: String?
    let instructor: String?
    let focusAreas: [String]
    let techniquesWorked: [String]
    let notes: String?
    let preSessionMood: Int?
    let postSessionMood: Int?
    let roundsCount: Int
    let whatWorkedWell: String?
    let needsImprovement: String?
    let keyInsights: String?
}

@MainActor
protocol SessionEntryInteractor: GlobalInteractor {
    var currentBeltEnum: BJJBelt { get }
    var gyms: [GymLocationModel] { get }
    var allTechniques: [TechniqueModel] { get }
    func createTechnique(name: String, category: TechniqueCategory)
    func logSessionWithGamification(_ params: SessionEntryParams) async throws -> BJJSessionModel
}

extension CoreInteractor: SessionEntryInteractor { }
