import Testing
import Foundation
@testable import Waza

// MARK: - Goal CRUD

@Suite("GoalManager - CRUD") @MainActor
struct GoalManagerCRUDTests {

    func makeManager() -> GoalManager {
        GoalManager(services: MockGoalServices(), logger: nil)
    }

    @Test("createGoal adds the goal to the goals array")
    func createGoal() throws {
        // GIVEN
        let manager = makeManager()
        #expect(manager.goals.isEmpty)

        // WHEN
        let goal = try manager.createGoal(title: "Learn triangle", goalType: .technique)

        // THEN
        #expect(manager.goals.count == 1)
        #expect(manager.goals.first?.goalId == goal.goalId)
        #expect(manager.goals.first?.title == "Learn triangle")
        #expect(manager.goals.first?.goalType == .technique)
    }

    @Test("createGoal stores optional fields when provided")
    func createGoalWithOptionalFields() throws {
        // GIVEN
        let manager = makeManager()
        let deadline = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

        // WHEN
        try manager.createGoal(
            title: "Competition goal",
            description: "Enter a local tournament",
            goalType: .competition,
            deadline: deadline
        )

        // THEN
        let stored = manager.goals.first
        #expect(stored?.goalDescription == "Enter a local tournament")
        #expect(stored?.deadline != nil)
    }

    @Test("updateGoal persists title and description changes")
    func updateGoal() throws {
        // GIVEN
        let manager = makeManager()
        var goal = try manager.createGoal(title: "Original title")

        // WHEN
        goal.title = "Updated title"
        goal.goalDescription = "New description"
        try manager.updateGoal(goal)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.title == "Updated title")
        #expect(updated?.goalDescription == "New description")
    }

    @Test("deleteGoal removes it from the goals array")
    func deleteGoal() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Goal to delete")
        #expect(manager.goals.count == 1)

        // WHEN
        try manager.deleteGoal(goal)

        // THEN
        #expect(manager.goals.isEmpty)
    }

    @Test("Creating multiple goals accumulates correctly")
    func createMultipleGoals() throws {
        // GIVEN
        let manager = makeManager()

        // WHEN
        try manager.createGoal(title: "Goal 1", goalType: .technique)
        try manager.createGoal(title: "Goal 2", goalType: .fitness)
        try manager.createGoal(title: "Goal 3", goalType: .attendance)

        // THEN
        #expect(manager.goals.count == 3)
    }

    @Test("Deleting one of many goals leaves the rest intact")
    func deleteOneOfManyGoals() throws {
        // GIVEN
        let manager = makeManager()
        let toDelete = try manager.createGoal(title: "Delete me")
        try manager.createGoal(title: "Keep me")

        // WHEN
        try manager.deleteGoal(toDelete)

        // THEN
        #expect(manager.goals.count == 1)
        #expect(manager.goals.first?.title == "Keep me")
    }
}

// MARK: - Goal Progress

@Suite("GoalManager - Progress") @MainActor
struct GoalManagerProgressTests {

    func makeManager() -> GoalManager {
        GoalManager(services: MockGoalServices(), logger: nil)
    }

    @Test("updateProgress changes the goal's progress value")
    func updateProgress() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Technique goal")
        #expect(manager.goals.first?.progress == 0)

        // WHEN
        try manager.updateProgress(goalId: goal.goalId, progress: 0.6)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.progress == 0.6)
    }

    @Test("updateProgress clamps values above 1.0 to 1.0")
    func updateProgressClampsHigh() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Clamping test")

        // WHEN
        try manager.updateProgress(goalId: goal.goalId, progress: 1.5)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.progress == 1.0)
    }

    @Test("updateProgress clamps values below 0.0 to 0.0")
    func updateProgressClampsLow() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Clamping test")

        // WHEN
        try manager.updateProgress(goalId: goal.goalId, progress: -0.5)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.progress == 0.0)
    }

    @Test("updateProgress auto-completes the goal when progress reaches 1.0")
    func updateProgressAutoCompletes() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Auto-complete test")
        #expect(manager.goals.first?.isCompleted == false)

        // WHEN
        try manager.updateProgress(goalId: goal.goalId, progress: 1.0)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.isCompleted == true)
        #expect(updated?.completedDate != nil)
    }

    @Test("updateProgress does not mark complete below 1.0")
    func updateProgressDoesNotAutoCompleteBelowFull() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "No auto-complete test")

        // WHEN
        try manager.updateProgress(goalId: goal.goalId, progress: 0.99)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.isCompleted == false)
    }

    @Test("completeGoal marks the goal as complete with progress 1.0")
    func completeGoal() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Goal to complete")

        // WHEN
        try manager.completeGoal(goalId: goal.goalId)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.isCompleted == true)
        #expect(updated?.progress == 1.0)
    }

    @Test("completeGoal sets a completedDate")
    func completeGoalSetsDate() throws {
        // GIVEN
        let manager = makeManager()
        let goal = try manager.createGoal(title: "Goal needing date")
        #expect(manager.goals.first?.completedDate == nil)

        // WHEN
        try manager.completeGoal(goalId: goal.goalId)

        // THEN
        let updated = manager.goals.first(where: { $0.goalId == goal.goalId })
        #expect(updated?.completedDate != nil)
    }
}

// MARK: - Goal Filtered Views

@Suite("GoalManager - FilteredViews") @MainActor
struct GoalManagerFilteredViewTests {

    func makeManager() -> GoalManager {
        GoalManager(services: MockGoalServices(), logger: nil)
    }

    @Test("activeGoals returns only incomplete goals")
    func activeGoals() throws {
        // GIVEN
        let manager = makeManager()
        let active = try manager.createGoal(title: "Active goal")
        let toComplete = try manager.createGoal(title: "Completed goal")
        try manager.completeGoal(goalId: toComplete.goalId)

        // WHEN
        let result = manager.activeGoals

        // THEN
        #expect(result.count == 1)
        #expect(result.first?.goalId == active.goalId)
    }

    @Test("completedGoals returns only complete goals")
    func completedGoals() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createGoal(title: "Still active")
        let toComplete = try manager.createGoal(title: "This will be done")
        try manager.completeGoal(goalId: toComplete.goalId)

        // WHEN
        let result = manager.completedGoals

        // THEN
        #expect(result.count == 1)
        #expect(result.first?.goalId == toComplete.goalId)
    }

    @Test("activeGoals and completedGoals partition all goals without overlap")
    func partitioning() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createGoal(title: "Goal 1")
        try manager.createGoal(title: "Goal 2")
        let goal3 = try manager.createGoal(title: "Goal 3")
        try manager.completeGoal(goalId: goal3.goalId)

        // WHEN
        let active = manager.activeGoals
        let completed = manager.completedGoals

        // THEN
        #expect(active.count + completed.count == manager.goals.count)
        #expect(active.count == 2)
        #expect(completed.count == 1)
    }

    @Test("activeGoals is empty when all goals are completed")
    func allCompleted() throws {
        // GIVEN
        let manager = makeManager()
        let goal1 = try manager.createGoal(title: "G1")
        let goal2 = try manager.createGoal(title: "G2")
        try manager.completeGoal(goalId: goal1.goalId)
        try manager.completeGoal(goalId: goal2.goalId)

        // WHEN / THEN
        #expect(manager.activeGoals.isEmpty)
        #expect(manager.completedGoals.count == 2)
    }
}

// MARK: - Goal Lifecycle

@Suite("GoalManager - Lifecycle") @MainActor
struct GoalManagerLifecycleTests {

    func makeManager() -> GoalManager {
        GoalManager(services: MockGoalServices(), logger: nil)
    }

    @Test("clearAll removes all goals")
    func clearAll() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createGoal(title: "G1")
        try manager.createGoal(title: "G2")
        #expect(manager.goals.count == 2)

        // WHEN
        manager.clearAll()

        // THEN
        #expect(manager.goals.isEmpty)
    }

    @Test("seedMockDataIfEmpty populates goals when empty")
    func seedMockDataIfEmpty() {
        // GIVEN
        let manager = makeManager()
        #expect(manager.goals.isEmpty)

        // WHEN
        manager.seedMockDataIfEmpty()

        // THEN
        #expect(!manager.goals.isEmpty)
    }

    @Test("seedMockDataIfEmpty does not overwrite existing goals")
    func seedMockDataDoesNotOverwrite() throws {
        // GIVEN
        let manager = makeManager()
        try manager.createGoal(title: "My original goal")
        let countBefore = manager.goals.count

        // WHEN
        manager.seedMockDataIfEmpty()

        // THEN
        #expect(manager.goals.count == countBefore)
        #expect(manager.goals.first?.title == "My original goal")
    }
}

// MARK: - Metric Goals

@Suite("GoalManager - Metric Goals") @MainActor
struct GoalManagerMetricTests {

    func makeGoalManager() -> GoalManager {
        GoalManager(services: MockGoalServices(), logger: nil)
    }

    func makeSessionManager() -> SessionManager {
        SessionManager(services: MockBJJSessionServices(), logger: nil)
    }

    @Test("createMetricGoal generates correct title")
    func createMetricGoalTitle() throws {
        // GIVEN
        let goals = makeGoalManager()

        // WHEN
        let goal = try goals.createMetricGoal(metric: .sessionsPerWeek, targetValue: 4)

        // THEN
        #expect(goal.title == "Train 4x per week")
        #expect(goal.goalMetric == .sessionsPerWeek)
        #expect(goal.targetValue == 4)
        #expect(goal.isMetricGoal == true)
    }

    @Test("createMetricGoal with focusArea generates correct title")
    func createMetricGoalFocusAreaTitle() throws {
        // GIVEN
        let goals = makeGoalManager()

        // WHEN
        let goal = try goals.createMetricGoal(metric: .focusAreaSessions, targetValue: 5, focusArea: "Guard")

        // THEN
        #expect(goal.title == "Train Guard 5x")
        #expect(goal.focusArea == "Guard")
    }

    @Test("computeProgress for sessionsPerWeek")
    func sessionsPerWeekProgress() throws {
        // GIVEN
        let goals = makeGoalManager()
        let sessions = makeSessionManager()
        try sessions.createSession(date: Date(), duration: 3600)
        try sessions.createSession(date: Date(), duration: 3600)

        // WHEN
        let goal = try goals.createMetricGoal(metric: .sessionsPerWeek, targetValue: 4)
        let progress = goals.computeProgress(for: goal, sessions: sessions.sessions)

        // THEN
        #expect(progress == 0.5) // 2/4
    }

    @Test("computeProgress clamps at 1.0")
    func progressClamp() throws {
        // GIVEN
        let goals = makeGoalManager()
        let sessions = makeSessionManager()
        for _ in 0..<6 {
            try sessions.createSession(date: Date(), duration: 3600)
        }

        // WHEN
        let goal = try goals.createMetricGoal(metric: .sessionsPerWeek, targetValue: 3)
        let progress = goals.computeProgress(for: goal, sessions: sessions.sessions)

        // THEN
        #expect(progress == 1.0)
    }

    @Test("computeProgress for focusAreaSessions")
    func focusAreaProgress() throws {
        // GIVEN
        let goals = makeGoalManager()
        let sessions = makeSessionManager()
        try sessions.createSession(focusAreas: ["Guard", "Passing"])
        try sessions.createSession(focusAreas: ["Takedowns"])
        try sessions.createSession(focusAreas: ["Guard"])

        // WHEN
        let goal = try goals.createMetricGoal(metric: .focusAreaSessions, targetValue: 5, focusArea: "Guard")
        let progress = goals.computeProgress(for: goal, sessions: sessions.sessions)

        // THEN
        #expect(progress == 0.4) // 2/5
    }

    @Test("legacy goals use stored progress")
    func legacyGoalProgress() throws {
        // GIVEN
        let goals = makeGoalManager()
        let sessions = makeSessionManager()
        let goal = try goals.createGoal(title: "Custom goal", goalType: .custom)
        try goals.updateProgress(goalId: goal.goalId, progress: 0.7)

        // WHEN
        let updatedGoal = goals.activeGoals.first!
        let progress = goals.computeProgress(for: updatedGoal, sessions: sessions.sessions)

        // THEN
        #expect(progress == 0.7)
    }

    @Test("currentValue returns raw count for metric goals")
    func currentValueForMetricGoal() throws {
        // GIVEN
        let goals = makeGoalManager()
        let sessions = makeSessionManager()
        try sessions.createSession(date: Date(), duration: 3600)
        try sessions.createSession(date: Date(), duration: 3600)
        try sessions.createSession(date: Date(), duration: 3600)

        // WHEN
        let goal = try goals.createMetricGoal(metric: .sessionsPerWeek, targetValue: 5)
        let value = goals.currentValue(for: goal, sessions: sessions.sessions)

        // THEN
        #expect(value == 3.0)
    }
}
