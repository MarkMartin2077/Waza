import SwiftData
import Foundation

@Observable
@MainActor
class BeltManager {
    private let modelContext: ModelContext

    private(set) var beltHistory: [BeltRecordModel] = []

    var currentBelt: BeltRecordModel? {
        beltHistory.max { lhs, rhs in
            let lhsScore = (BJJBelt(rawValue: lhs.beltRaw)?.order ?? 0) * 5 + lhs.stripes
            let rhsScore = (BJJBelt(rawValue: rhs.beltRaw)?.order ?? 0) * 5 + rhs.stripes
            return lhsScore < rhsScore
        }
    }

    var currentBeltEnum: BJJBelt {
        currentBelt?.belt ?? .white
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<BeltRecordModel>(
            sortBy: [SortDescriptor(\.promotionDate, order: .reverse)]
        )
        beltHistory = (try? modelContext.fetch(descriptor)) ?? []
    }

    @discardableResult
    func addPromotion(
        belt: BJJBelt,
        stripes: Int = 0,
        date: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) throws -> BeltRecordModel {
        let record = BeltRecordModel(
            belt: belt,
            stripes: stripes,
            promotionDate: date,
            academy: academy,
            notes: notes
        )
        modelContext.insert(record)
        try modelContext.save()
        refresh()
        return record
    }

    func deletePromotion(_ record: BeltRecordModel) throws {
        modelContext.delete(record)
        try modelContext.save()
        refresh()
    }

    func estimatedTimeToNextBelt(sessionsPerWeek: Double = 3) -> String? {
        guard let current = currentBelt,
              let belt = BJJBelt(rawValue: current.beltRaw),
              let years = belt.typicalYearsToNext else {
            return nil
        }
        let adjustedYears = years * (3.0 / max(sessionsPerWeek, 0.5))
        if adjustedYears < 1 {
            let months = Int(adjustedYears * 12)
            return "\(months) months"
        }
        return String(format: "%.1f years", adjustedYears)
    }

    func seedMockDataIfEmpty() {
        guard beltHistory.isEmpty else { return }
        for record in BeltRecordModel.mocks {
            modelContext.insert(record)
        }
        try? modelContext.save()
        refresh()
    }
}
