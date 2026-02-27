import SwiftData
import Foundation

@Model
final class BeltRecordModel {
    @Attribute(.unique) var id: String
    var beltRaw: String
    var stripes: Int
    var promotionDate: Date
    var academy: String?
    var notes: String?

    var belt: BJJBelt {
        get { BJJBelt(rawValue: beltRaw) ?? .white }
        set { beltRaw = newValue.rawValue }
    }

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

    init(
        id: String = UUID().uuidString,
        belt: BJJBelt = .white,
        stripes: Int = 0,
        promotionDate: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.beltRaw = belt.rawValue
        self.stripes = max(0, min(4, stripes))
        self.promotionDate = promotionDate
        self.academy = academy
        self.notes = notes
    }
}

extension BeltRecordModel {
    static var mock: BeltRecordModel {
        BeltRecordModel(
            id: "mock-belt-1",
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
                id: "mock-belt-white",
                belt: .white,
                stripes: 4,
                promotionDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                academy: "Gracie Barra"
            ),
            mock
        ]
    }
}
