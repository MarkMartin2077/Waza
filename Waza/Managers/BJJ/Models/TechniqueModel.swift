import Foundation
import IdentifiableByString

struct TechniqueModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var techniqueId: String
    var name: String
    var category: TechniqueCategory
    var stage: ProgressionStage
    var notes: String?
    var createdDate: Date
    var lastStageChangeDate: Date?

    var id: String { techniqueId }

    init(
        techniqueId: String = UUID().uuidString,
        name: String,
        category: TechniqueCategory = .uncategorized,
        stage: ProgressionStage = .learning,
        notes: String? = nil,
        createdDate: Date = Date(),
        lastStageChangeDate: Date? = nil
    ) {
        self.techniqueId = techniqueId
        self.name = name
        self.category = category
        self.stage = stage
        self.notes = notes
        self.createdDate = createdDate
        self.lastStageChangeDate = lastStageChangeDate
    }

    init(entity: TechniqueEntity) {
        self.techniqueId = entity.techniqueId
        self.name = entity.name
        self.category = TechniqueCategory(rawValue: entity.categoryRaw) ?? .uncategorized
        self.stage = ProgressionStage(rawValue: entity.stageRaw) ?? .learning
        self.notes = entity.notes
        self.createdDate = entity.createdDate
        self.lastStageChangeDate = entity.lastStageChangeDate
    }

    func toEntity() -> TechniqueEntity {
        TechniqueEntity(from: self)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case techniqueId = "technique_id"
        case name
        case category
        case stage
        case notes
        case createdDate = "created_date"
        case lastStageChangeDate = "last_stage_change_date"
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "technique_id": techniqueId,
            "technique_name": name,
            "technique_category": category.rawValue,
            "technique_stage": stage.rawValue,
            "created_date": createdDate.timeIntervalSince1970
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension TechniqueModel {
    static var mock: TechniqueModel {
        TechniqueModel(
            techniqueId: "mock-technique-1",
            name: "Triangle",
            category: .submissions,
            stage: .drilling,
            notes: "Focus on hip angle and leg positioning.",
            createdDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        )
    }

    static var mocks: [TechniqueModel] {
        [
            TechniqueModel(
                techniqueId: "mock-technique-1",
                name: "Triangle",
                category: .submissions,
                stage: .drilling,
                notes: "Focus on hip angle.",
                createdDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-2",
                name: "Armbar",
                category: .submissions,
                stage: .applying,
                createdDate: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-3",
                name: "Guard Passing",
                category: .passing,
                stage: .learning,
                notes: "Torreando and leg drag series.",
                createdDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-4",
                name: "Back Takes",
                category: .guardPlay,
                stage: .drilling,
                createdDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-5",
                name: "Takedowns",
                category: .takedowns,
                stage: .learning,
                createdDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-6",
                name: "Wrestling",
                category: .takedowns,
                stage: .drilling,
                notes: "Double leg and snapdowns.",
                createdDate: Calendar.current.date(byAdding: .month, value: -5, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-7",
                name: "Guard Retention",
                category: .guardPlay,
                stage: .applying,
                createdDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-8",
                name: "Sweeps",
                category: .sweeps,
                stage: .polishing,
                notes: "Scissor sweep and hip bump series.",
                createdDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-9",
                name: "Leg Locks",
                category: .submissions,
                stage: .learning,
                createdDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date()
            ),
            TechniqueModel(
                techniqueId: "mock-technique-10",
                name: "Half Guard",
                category: .guardPlay,
                stage: .drilling,
                notes: "Underhook battle and dog fight.",
                createdDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
            )
        ]
    }
}
