import SwiftData
import Foundation

@MainActor
class BJJDataManager {
    let modelContainer: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([
            BJJSessionEntity.self,
            BeltRecordEntity.self,
            TrainingGoalEntity.self,
            AchievementEarnedEntity.self,
            CLAGameEntity.self,
            GameDiscoveryEntity.self
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
