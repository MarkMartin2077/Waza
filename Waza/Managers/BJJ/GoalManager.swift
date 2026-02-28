import Foundation

@Observable
@MainActor
class GoalManager {
    private let localService: GoalLocalService
    private let remoteService: RemoteGoalService
    private let logger: LogManager?
    private var userId: String?

    private(set) var goals: [TrainingGoalModel] = []

    var activeGoals: [TrainingGoalModel] {
        goals.filter { !$0.isCompleted }
    }

    var completedGoals: [TrainingGoalModel] {
        goals.filter { $0.isCompleted }
    }

    init(services: GoalServices, logger: LogManager? = nil) {
        self.localService = services.local
        self.remoteService = services.remote
        self.logger = logger
        refresh()
    }

    // MARK: - Lifecycle

    /// Synchronous — returns immediately; merges remote-only records in the background.
    func logIn(userId: String) {
        self.userId = userId
        guard BJJSyncHelper.shouldSync(key: BJJSyncHelper.goalsSyncKey) else { return }
        Task { await syncFromRemote(userId: userId) }
    }

    func logOut() {
        userId = nil
    }

    // MARK: - Read

    func refresh() {
        goals = localService.getGoals()
    }

    // MARK: - Write

    @discardableResult
    func createGoal(
        title: String,
        description: String? = nil,
        goalType: GoalType = .custom,
        deadline: Date? = nil
    ) throws -> TrainingGoalModel {
        let model = TrainingGoalModel(
            title: title,
            goalDescription: description,
            goalType: goalType,
            deadline: deadline
        )
        try localService.create(model)
        refresh()
        syncToRemote(model)
        return model
    }

    func updateProgress(goalId: String, progress: Double) throws {
        guard var goal = goals.first(where: { $0.goalId == goalId }) else { return }
        goal.progress = min(max(progress, 0), 1.0)
        if goal.progress >= 1.0 && !goal.isCompleted {
            goal.isCompleted = true
            goal.completedDate = Date()
        }
        try localService.update(goal)
        refresh()
        syncToRemote(goal)
    }

    func completeGoal(goalId: String) throws {
        guard var goal = goals.first(where: { $0.goalId == goalId }) else { return }
        goal.isCompleted = true
        goal.progress = 1.0
        goal.completedDate = Date()
        try localService.update(goal)
        refresh()
        syncToRemote(goal)
    }

    func updateGoal(_ model: TrainingGoalModel) throws {
        try localService.update(model)
        refresh()
        syncToRemote(model)
    }

    func deleteGoal(_ model: TrainingGoalModel) throws {
        try localService.delete(id: model.goalId)
        refresh()
        deleteFromRemote(id: model.goalId)
    }

    // MARK: - Wipe

    func clearAll() {
        logOut()
        try? localService.deleteAll()
        goals = []
        BJJSyncHelper.clearSyncTimestamp(key: BJJSyncHelper.goalsSyncKey)
    }

    func seedMockDataIfEmpty() {
        guard goals.isEmpty else { return }
        for model in TrainingGoalModel.mocks {
            try? localService.create(model)
        }
        refresh()
    }

    // MARK: - Private

    private func syncFromRemote(userId: String) async {
        do {
            let remoteModels = try await remoteService.getGoals(userId: userId)
            let localIds = Set(goals.map { $0.goalId })
            var changed = false
            for model in remoteModels where !localIds.contains(model.goalId) {
                try? localService.create(model)
                changed = true
            }
            if changed { refresh() }
            BJJSyncHelper.markSynced(key: BJJSyncHelper.goalsSyncKey)
        } catch {
            logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "GoalManager", context: "Sync", error: error))
        }
    }

    private func syncToRemote(_ model: TrainingGoalModel) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.saveGoal(model, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "GoalManager", context: "Save", error: error))
            }
        }
    }

    private func deleteFromRemote(id: String) {
        guard let userId else { return }
        Task {
            do {
                try await remoteService.deleteGoal(id: id, userId: userId)
            } catch {
                logger?.trackEvent(event: BJJSyncErrorEvent(managerName: "GoalManager", context: "Delete", error: error))
            }
        }
    }
}
