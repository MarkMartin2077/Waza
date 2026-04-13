import SwiftData
import Foundation

@Model
final class TechniqueEntity {
    @Attribute(.unique) var techniqueId: String
    var name: String
    var categoryRaw: String
    var stageRaw: String
    var notes: String?
    var createdDate: Date
    var lastStageChangeDate: Date?

    init(
        techniqueId: String = UUID().uuidString,
        name: String = "",
        categoryRaw: String = "uncategorized",
        stageRaw: String = "learning",
        notes: String? = nil,
        createdDate: Date = Date(),
        lastStageChangeDate: Date? = nil
    ) {
        self.techniqueId = techniqueId
        self.name = name
        self.categoryRaw = categoryRaw
        self.stageRaw = stageRaw
        self.notes = notes
        self.createdDate = createdDate
        self.lastStageChangeDate = lastStageChangeDate
    }

    convenience init(from model: TechniqueModel) {
        self.init(
            techniqueId: model.techniqueId,
            name: model.name,
            categoryRaw: model.category.rawValue,
            stageRaw: model.stage.rawValue,
            notes: model.notes,
            createdDate: model.createdDate,
            lastStageChangeDate: model.lastStageChangeDate
        )
    }

    func toModel() -> TechniqueModel {
        TechniqueModel(
            techniqueId: techniqueId,
            name: name,
            category: TechniqueCategory(rawValue: categoryRaw) ?? .uncategorized,
            stage: ProgressionStage(rawValue: stageRaw) ?? .learning,
            notes: notes,
            createdDate: createdDate,
            lastStageChangeDate: lastStageChangeDate
        )
    }

    func update(from model: TechniqueModel) {
        name = model.name
        categoryRaw = model.category.rawValue
        stageRaw = model.stage.rawValue
        notes = model.notes
        lastStageChangeDate = model.lastStageChangeDate
    }
}
