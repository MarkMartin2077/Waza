import Foundation

struct CLAGameModel: Codable, Sendable, Identifiable {
    var gameId: String
    var name: String
    var objective: String
    var skillLevel: BeltLevel
    var position: String
    var focusArea: String
    var taskConstraints: [String]
    var environmentConstraints: [String]
    var individualConstraints: [String]
    var expectedDiscoveries: [String]
    var safetyNotes: String?
    var isCustom: Bool
    var isAIGenerated: Bool
    var timePracticed: Int
    var avgSuccessRating: Double
    var discoveries: [GameDiscoveryModel]

    var id: String { gameId }

    init(
        gameId: String = UUID().uuidString,
        name: String,
        objective: String,
        skillLevel: BeltLevel = .all,
        position: String,
        focusArea: String,
        taskConstraints: [String] = [],
        environmentConstraints: [String] = [],
        individualConstraints: [String] = [],
        expectedDiscoveries: [String] = [],
        safetyNotes: String? = nil,
        isCustom: Bool = false,
        isAIGenerated: Bool = false,
        timePracticed: Int = 0,
        avgSuccessRating: Double = 0,
        discoveries: [GameDiscoveryModel] = []
    ) {
        self.gameId = gameId
        self.name = name
        self.objective = objective
        self.skillLevel = skillLevel
        self.position = position
        self.focusArea = focusArea
        self.taskConstraints = taskConstraints
        self.environmentConstraints = environmentConstraints
        self.individualConstraints = individualConstraints
        self.expectedDiscoveries = expectedDiscoveries
        self.safetyNotes = safetyNotes
        self.isCustom = isCustom
        self.isAIGenerated = isAIGenerated
        self.timePracticed = timePracticed
        self.avgSuccessRating = avgSuccessRating
        self.discoveries = discoveries
    }

    init(entity: CLAGameEntity) {
        self.gameId = entity.gameId
        self.name = entity.name
        self.objective = entity.objective
        self.skillLevel = BeltLevel(rawValue: entity.skillLevelRaw) ?? .all
        self.position = entity.position
        self.focusArea = entity.focusArea
        self.taskConstraints = (try? JSONDecoder().decode([String].self, from: entity.taskConstraintsData)) ?? []
        self.environmentConstraints = (try? JSONDecoder().decode([String].self, from: entity.environmentConstraintsData)) ?? []
        self.individualConstraints = (try? JSONDecoder().decode([String].self, from: entity.individualConstraintsData)) ?? []
        self.expectedDiscoveries = (try? JSONDecoder().decode([String].self, from: entity.expectedDiscoveriesData)) ?? []
        self.safetyNotes = entity.safetyNotes
        self.isCustom = entity.isCustom
        self.isAIGenerated = entity.isAIGenerated
        self.timePracticed = entity.timePracticed
        self.avgSuccessRating = entity.avgSuccessRating
        self.discoveries = entity.discoveries.map { $0.toModel() }
    }

    func toEntity() -> CLAGameEntity {
        CLAGameEntity(from: self)
    }

    enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
        case name
        case objective
        case skillLevel = "skill_level"
        case position
        case focusArea = "focus_area"
        case taskConstraints = "task_constraints"
        case environmentConstraints = "environment_constraints"
        case individualConstraints = "individual_constraints"
        case expectedDiscoveries = "expected_discoveries"
        case safetyNotes = "safety_notes"
        case isCustom = "is_custom"
        case isAIGenerated = "is_ai_generated"
        case timePracticed = "time_practiced"
        case avgSuccessRating = "avg_success_rating"
        case discoveries
    }

    var eventParameters: [String: Any] {
        [
            "game_id": gameId,
            "game_name": name,
            "position": position,
            "is_custom": isCustom,
            "skill_level": skillLevel.rawValue,
            "discovery_count": discoveries.count
        ]
    }

    static var mocks: [CLAGameModel] {
        Array(CLAGameLibrary.allGames.prefix(3))
    }
}
