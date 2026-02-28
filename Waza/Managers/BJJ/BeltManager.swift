import Foundation

@Observable
@MainActor
class BeltManager {
    private let localService: BeltLocalService
    private let remoteService: RemoteBeltService

    private(set) var beltHistory: [BeltRecordModel] = []

    var currentBelt: BeltRecordModel? {
        beltHistory.max { lhs, rhs in
            let lhsScore = lhs.belt.order * 5 + lhs.stripes
            let rhsScore = rhs.belt.order * 5 + rhs.stripes
            return lhsScore < rhsScore
        }
    }

    var currentBeltEnum: BJJBelt {
        currentBelt?.belt ?? .white
    }

    init(services: BeltServices) {
        self.localService = services.local
        self.remoteService = services.remote
        refresh()
    }

    func refresh() {
        beltHistory = localService.getBeltHistory()
    }

    @discardableResult
    func addPromotion(
        belt: BJJBelt,
        stripes: Int = 0,
        date: Date = Date(),
        academy: String? = nil,
        notes: String? = nil
    ) throws -> BeltRecordModel {
        let model = BeltRecordModel(
            belt: belt,
            stripes: stripes,
            promotionDate: date,
            academy: academy,
            notes: notes
        )
        try localService.create(model)
        refresh()
        return model
    }

    func deletePromotion(_ model: BeltRecordModel) throws {
        try localService.delete(id: model.beltRecordId)
        refresh()
    }

    func estimatedTimeToNextBelt(sessionsPerWeek: Double = 3) -> String? {
        guard let years = currentBeltEnum.typicalYearsToNext else { return nil }
        let adjustedYears = years * (3.0 / max(sessionsPerWeek, 0.5))
        if adjustedYears < 1 {
            let months = Int(adjustedYears * 12)
            return "\(months) months"
        }
        return String(format: "%.1f years", adjustedYears)
    }

    func seedMockDataIfEmpty() {
        guard beltHistory.isEmpty else { return }
        for model in BeltRecordModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }
}
