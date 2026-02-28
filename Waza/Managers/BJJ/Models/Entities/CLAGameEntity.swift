import SwiftData
import Foundation

@Model
final class CLAGameEntity {
    @Attribute(.unique) var gameId: String
    var name: String
    var objective: String
    var skillLevelRaw: String
    var position: String
    var focusArea: String
    var taskConstraintsData: Data
    var environmentConstraintsData: Data
    var individualConstraintsData: Data
    var expectedDiscoveriesData: Data
    var safetyNotes: String?
    var isCustom: Bool
    var isAIGenerated: Bool
    var timePracticed: Int
    var avgSuccessRating: Double
    @Relationship(deleteRule: .cascade) var discoveries: [GameDiscoveryEntity]

    init(
        gameId: String,
        name: String,
        objective: String,
        skillLevelRaw: String,
        position: String,
        focusArea: String,
        taskConstraintsData: Data,
        environmentConstraintsData: Data,
        individualConstraintsData: Data,
        expectedDiscoveriesData: Data,
        safetyNotes: String?,
        isCustom: Bool,
        isAIGenerated: Bool,
        timePracticed: Int,
        avgSuccessRating: Double
    ) {
        self.gameId = gameId
        self.name = name
        self.objective = objective
        self.skillLevelRaw = skillLevelRaw
        self.position = position
        self.focusArea = focusArea
        self.taskConstraintsData = taskConstraintsData
        self.environmentConstraintsData = environmentConstraintsData
        self.individualConstraintsData = individualConstraintsData
        self.expectedDiscoveriesData = expectedDiscoveriesData
        self.safetyNotes = safetyNotes
        self.isCustom = isCustom
        self.isAIGenerated = isAIGenerated
        self.timePracticed = timePracticed
        self.avgSuccessRating = avgSuccessRating
        self.discoveries = []
    }

    convenience init(from model: CLAGameModel) {
        let encode: ([String]) -> Data = { (try? JSONEncoder().encode($0)) ?? Data() }
        self.init(
            gameId: model.gameId,
            name: model.name,
            objective: model.objective,
            skillLevelRaw: model.skillLevel.rawValue,
            position: model.position,
            focusArea: model.focusArea,
            taskConstraintsData: encode(model.taskConstraints),
            environmentConstraintsData: encode(model.environmentConstraints),
            individualConstraintsData: encode(model.individualConstraints),
            expectedDiscoveriesData: encode(model.expectedDiscoveries),
            safetyNotes: model.safetyNotes,
            isCustom: model.isCustom,
            isAIGenerated: model.isAIGenerated,
            timePracticed: model.timePracticed,
            avgSuccessRating: model.avgSuccessRating
        )
    }

    func toModel() -> CLAGameModel {
        CLAGameModel(entity: self)
    }

    func update(from model: CLAGameModel) {
        let encode: ([String]) -> Data = { (try? JSONEncoder().encode($0)) ?? Data() }
        name = model.name
        objective = model.objective
        skillLevelRaw = model.skillLevel.rawValue
        position = model.position
        focusArea = model.focusArea
        taskConstraintsData = encode(model.taskConstraints)
        environmentConstraintsData = encode(model.environmentConstraints)
        individualConstraintsData = encode(model.individualConstraints)
        expectedDiscoveriesData = encode(model.expectedDiscoveries)
        safetyNotes = model.safetyNotes
        isCustom = model.isCustom
        isAIGenerated = model.isAIGenerated
        timePracticed = model.timePracticed
        avgSuccessRating = model.avgSuccessRating
    }
}
