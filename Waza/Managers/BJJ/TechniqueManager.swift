import Foundation

@Observable
@MainActor
class TechniqueManager {
    private let localService: TechniqueLocalService
    private let remoteService: RemoteTechniqueService
    private let logger: LogManager?
    private var userId: String?

    private(set) var techniques: [TechniqueModel] = []

    init(services: TechniqueServicesProtocol, logger: LogManager? = nil) {
        self.localService = services.local
        self.remoteService = services.remote
        self.logger = logger
        refresh()
    }

    // MARK: - Lifecycle

    /// Synchronous — returns immediately; merges remote-only records in the background.
    func logIn(userId: String) {
        self.userId = userId
        guard BJJSyncHelper.shouldSync(key: BJJSyncHelper.techniquesSyncKey, userId: userId) else { return }
        Task { await syncFromRemote(userId: userId) }
    }

    func logOut() {
        userId = nil
    }

    // MARK: - Read

    func refresh() {
        techniques = localService.getTechniques()
    }

    // MARK: - Write

    @discardableResult
    func createTechnique(
        name: String,
        category: TechniqueCategory = .uncategorized,
        stage: ProgressionStage = .learning,
        notes: String? = nil
    ) throws -> TechniqueModel {
        let model = TechniqueModel(name: name, category: category, stage: stage, notes: notes)
        try localService.create(model)
        refresh()
        syncToRemote(model)
        return model
    }

    func updateTechnique(_ model: TechniqueModel) throws {
        try localService.update(model)
        refresh()
        syncToRemote(model)
    }

    func deleteTechnique(_ model: TechniqueModel) throws {
        try localService.delete(id: model.techniqueId)
        refresh()
        deleteFromRemote(id: model.techniqueId)
    }

    // MARK: - Ensure Techniques Exist

    /// For each focus area name, if no matching technique exists (case-insensitive), creates one
    /// with the inferred category at `.learning` stage.
    func ensureTechniquesExist(for focusAreas: [String]) {
        let existingNames = Set(techniques.map { $0.name.lowercased() })
        for name in focusAreas {
            guard !existingNames.contains(name.lowercased()) else { continue }
            let category = TechniqueCategory.infer(from: name)
            try? createTechnique(name: name, category: category, stage: .learning)
        }
    }

    // MARK: - Wipe

    func clearAll() {
        if let userId {
            BJJSyncHelper.clearSyncTimestamp(key: BJJSyncHelper.techniquesSyncKey, userId: userId)
        }
        logOut()
        try? localService.deleteAll()
        techniques = []
    }

    func seedMockDataIfEmpty() {
        guard techniques.isEmpty else { return }
        for model in TechniqueModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }

    // MARK: - Private

    private func syncFromRemote(userId: String) async {
        do {
            let remoteModels = try await remoteService.getTechniques(userId: userId, limit: 500)
            let localIds = Set(techniques.map { $0.techniqueId })
            var changed = false
            for model in remoteModels where !localIds.contains(model.techniqueId) {
                try? localService.create(model)
                changed = true
            }
            if changed { refresh() }
            BJJSyncHelper.markSynced(key: BJJSyncHelper.techniquesSyncKey, userId: userId)
        } catch {
            logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "TechniqueManager", context: "Sync", error: error))
        }
    }

    private func syncToRemote(_ model: TechniqueModel) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.saveTechnique(model, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "TechniqueManager", context: "Save", error: error))
            }
        }
    }

    private func deleteFromRemote(id: String) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.deleteTechnique(id: id, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "TechniqueManager", context: "Delete", error: error))
            }
        }
    }
}
