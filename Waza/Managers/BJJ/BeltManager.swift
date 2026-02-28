import Foundation

@Observable
@MainActor
class BeltManager {
    private let localService: BeltLocalService
    private let remoteService: RemoteBeltService
    private let logger: LogManager?
    private var userId: String?

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

    init(services: BeltServices, logger: LogManager? = nil) {
        self.localService = services.local
        self.remoteService = services.remote
        self.logger = logger
        refresh()
    }

    // MARK: - Lifecycle

    /// Synchronous — returns immediately; merges remote-only records in the background.
    func logIn(userId: String) {
        self.userId = userId
        guard BJJSyncHelper.shouldSync(key: BJJSyncHelper.beltsSyncKey, userId: userId) else { return }
        Task { await syncFromRemote(userId: userId) }
    }

    func logOut() {
        userId = nil
    }

    // MARK: - Read

    func refresh() {
        beltHistory = localService.getBeltHistory()
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

    // MARK: - Write

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
        syncToRemote(model)
        return model
    }

    func deletePromotion(_ model: BeltRecordModel) throws {
        try localService.delete(id: model.beltRecordId)
        refresh()
        deleteFromRemote(id: model.beltRecordId)
    }

    // MARK: - Wipe

    func clearAll() {
        if let userId {
            BJJSyncHelper.clearSyncTimestamp(key: BJJSyncHelper.beltsSyncKey, userId: userId)
        }
        logOut()
        try? localService.deleteAll()
        beltHistory = []
    }

    func seedMockDataIfEmpty() {
        guard beltHistory.isEmpty else { return }
        for model in BeltRecordModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }

    // MARK: - Private

    private func syncFromRemote(userId: String) async {
        do {
            let remoteModels = try await remoteService.getBeltHistory(userId: userId)
            let localIds = Set(beltHistory.map { $0.beltRecordId })
            var changed = false
            for model in remoteModels where !localIds.contains(model.beltRecordId) {
                try? localService.create(model)
                changed = true
            }
            if changed { refresh() }
            BJJSyncHelper.markSynced(key: BJJSyncHelper.beltsSyncKey, userId: userId)
        } catch {
            logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "BeltManager", context: "Sync", error: error))
        }
    }

    private func syncToRemote(_ model: BeltRecordModel) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.saveRecord(model, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "BeltManager", context: "Save", error: error))
            }
        }
    }

    private func deleteFromRemote(id: String) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.deleteRecord(id: id, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "BeltManager", context: "Delete", error: error))
            }
        }
    }
}
