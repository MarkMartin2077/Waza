import Foundation
import IdentifiableByString

struct BeltRecordModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var beltRecordId: String
    var belt: BJJBelt
    var stripes: Int
    var promotionDate: Date
    var academy: String?
    var notes: String?

    var id: String { beltRecordId }

    init(
        beltRecordId: String = UUID().uuidString,
        belt: BJJBelt = .white,
        stripes: Int = 0,
        promotionDate: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) {
        self.beltRecordId = beltRecordId
        self.belt = belt
        self.stripes = max(0, min(4, stripes))
        self.promotionDate = promotionDate
        self.academy = academy
        self.notes = notes
    }

    init(entity: BeltRecordEntity) {
        self.beltRecordId = entity.beltRecordId
        self.belt = BJJBelt(rawValue: entity.beltRaw) ?? .white
        self.stripes = entity.stripes
        self.promotionDate = entity.promotionDate
        self.academy = entity.academy
        self.notes = entity.notes
    }

    func toEntity() -> BeltRecordEntity {
        BeltRecordEntity(from: self)
    }

    // MARK: - Computed Display Properties

    var displayTitle: String {
        let beltName = belt.displayName
        if stripes == 0 {
            return beltName
        }
        let stripeText = stripes == 1 ? "1 stripe" : "\(stripes) stripes"
        return "\(beltName) — \(stripeText)"
    }

    var promotionDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: promotionDate)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case beltRecordId = "belt_record_id"
        case belt
        case stripes
        case promotionDate = "promotion_date"
        case academy
        case notes
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "belt_record_id": beltRecordId,
            "belt": belt.rawValue,
            "stripes": stripes
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension BeltRecordModel {
    static var mock: BeltRecordModel {
        BeltRecordModel(
            beltRecordId: "mock-belt-1",
            belt: .blue,
            stripes: 2,
            promotionDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            academy: "Gracie Barra",
            notes: "Promoted after competing at the local tournament."
        )
    }

    static var mocks: [BeltRecordModel] {
        [
            BeltRecordModel(
                beltRecordId: "mock-belt-white",
                belt: .white,
                stripes: 4,
                promotionDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                academy: "Gracie Barra"
            ),
            mock
        ]
    }
}
