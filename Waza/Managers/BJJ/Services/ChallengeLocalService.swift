import SwiftData
import Foundation

// MARK: - Local Service Protocol

@MainActor
protocol ChallengeLocalService {
    func getChallenges() -> [WeeklyChallengeModel]
    func getChallenges(forWeek weekStart: Date) -> [WeeklyChallengeModel]
    func create(_ challenge: WeeklyChallengeModel) throws
    func update(_ challenge: WeeklyChallengeModel) throws
    func deleteAll() throws
}

// MARK: - SwiftData Implementation

@MainActor
struct SwiftDataChallengePersistence: ChallengeLocalService {
    private let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration("WeeklyChallenges", isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: WeeklyChallengeEntity.self, configurations: config)
    }

    func getChallenges() -> [WeeklyChallengeModel] {
        let descriptor = FetchDescriptor<WeeklyChallengeEntity>(
            sortBy: [SortDescriptor(\.weekStartDate, order: .reverse)]
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func getChallenges(forWeek weekStart: Date) -> [WeeklyChallengeModel] {
        // Use a 1-minute tolerance window to guard against floating-point timestamp drift.
        let tolerance: TimeInterval = 60
        let lower = weekStart.addingTimeInterval(-tolerance)
        let upper = weekStart.addingTimeInterval(tolerance)
        let descriptor = FetchDescriptor<WeeklyChallengeEntity>(
            predicate: #Predicate { $0.weekStartDate >= lower && $0.weekStartDate <= upper }
        )
        let entities = (try? container.mainContext.fetch(descriptor)) ?? []
        return entities.map { $0.toModel() }
    }

    func create(_ challenge: WeeklyChallengeModel) throws {
        let entity = WeeklyChallengeEntity(from: challenge)
        container.mainContext.insert(entity)
        try container.mainContext.save()
    }

    func update(_ challenge: WeeklyChallengeModel) throws {
        let idToMatch = challenge.challengeId
        let descriptor = FetchDescriptor<WeeklyChallengeEntity>(
            predicate: #Predicate { $0.challengeId == idToMatch }
        )
        guard let entity = (try? container.mainContext.fetch(descriptor))?.first else { return }
        entity.update(from: challenge)
        try container.mainContext.save()
    }

    func deleteAll() throws {
        try container.mainContext.delete(model: WeeklyChallengeEntity.self)
        try container.mainContext.save()
    }
}
