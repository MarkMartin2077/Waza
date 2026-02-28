import SwiftData
import Foundation

@Model
final class BeltRecordEntity {
    @Attribute(.unique) var beltRecordId: String
    var beltRaw: String
    var stripes: Int
    var promotionDate: Date
    var academy: String?
    var notes: String?

    init(
        beltRecordId: String = UUID().uuidString,
        beltRaw: String = "white",
        stripes: Int = 0,
        promotionDate: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) {
        self.beltRecordId = beltRecordId
        self.beltRaw = beltRaw
        self.stripes = max(0, min(4, stripes))
        self.promotionDate = promotionDate
        self.academy = academy
        self.notes = notes
    }

    convenience init(from model: BeltRecordModel) {
        self.init(
            beltRecordId: model.beltRecordId,
            beltRaw: model.belt.rawValue,
            stripes: model.stripes,
            promotionDate: model.promotionDate,
            academy: model.academy,
            notes: model.notes
        )
    }

    func toModel() -> BeltRecordModel {
        BeltRecordModel(
            beltRecordId: beltRecordId,
            belt: BJJBelt(rawValue: beltRaw) ?? .white,
            stripes: stripes,
            promotionDate: promotionDate,
            academy: academy,
            notes: notes
        )
    }

    func update(from model: BeltRecordModel) {
        beltRaw = model.belt.rawValue
        stripes = max(0, min(4, model.stripes))
        promotionDate = model.promotionDate
        academy = model.academy
        notes = model.notes
    }
}
