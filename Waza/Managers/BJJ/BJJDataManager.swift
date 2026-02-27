import SwiftData
import Foundation

@MainActor
class BJJDataManager {
    let modelContainer: ModelContainer

    var modelContext: ModelContext {
        modelContainer.mainContext
    }

    init(inMemory: Bool = false) {
        let schema = Schema([
            BJJSessionModel.self,
            BeltRecordModel.self,
            TrainingGoalModel.self,
            AchievementEarnedModel.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer for BJJ data: \(error)")
        }
    }
}
