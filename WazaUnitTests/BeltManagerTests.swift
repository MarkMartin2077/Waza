import Testing
import Foundation
@testable import Waza

// MARK: - Belt CRUD

@Suite("BeltManager - CRUD") @MainActor
struct BeltManagerCRUDTests {

    func makeManager() -> BeltManager {
        BeltManager(services: MockBeltServices(), logger: nil)
    }

    @Test("addPromotion adds a record to belt history")
    func addPromotion() throws {
        // GIVEN
        let manager = makeManager()
        #expect(manager.beltHistory.isEmpty)

        // WHEN
        let record = try manager.addPromotion(belt: .blue, stripes: 0)

        // THEN
        #expect(manager.beltHistory.count == 1)
        #expect(manager.beltHistory.first?.beltRecordId == record.beltRecordId)
        #expect(manager.beltHistory.first?.belt == .blue)
        #expect(manager.beltHistory.first?.stripes == 0)
    }

    @Test("addPromotion stores stripes correctly")
    func addPromotionWithStripes() throws {
        // GIVEN
        let manager = makeManager()

        // WHEN
        try manager.addPromotion(belt: .purple, stripes: 3)

        // THEN
        #expect(manager.beltHistory.first?.stripes == 3)
    }

    @Test("deletePromotion removes the record from belt history")
    func deletePromotion() throws {
        // GIVEN
        let manager = makeManager()
        let record = try manager.addPromotion(belt: .blue)
        #expect(manager.beltHistory.count == 1)

        // WHEN
        try manager.deletePromotion(record)

        // THEN
        #expect(manager.beltHistory.isEmpty)
    }

    @Test("Adding multiple promotions accumulates correctly")
    func addMultiplePromotions() throws {
        // GIVEN
        let manager = makeManager()

        // WHEN
        try manager.addPromotion(belt: .white, stripes: 4)
        try manager.addPromotion(belt: .blue, stripes: 0)
        try manager.addPromotion(belt: .blue, stripes: 2)

        // THEN
        #expect(manager.beltHistory.count == 3)
    }

    @Test("Deleting one of many records leaves the rest intact")
    func deleteOneOfManyRecords() throws {
        // GIVEN
        let manager = makeManager()
        let toDelete = try manager.addPromotion(belt: .white, stripes: 4)
        try manager.addPromotion(belt: .blue, stripes: 0)

        // WHEN
        try manager.deletePromotion(toDelete)

        // THEN
        #expect(manager.beltHistory.count == 1)
        #expect(manager.beltHistory.first?.belt == .blue)
    }
}

// MARK: - Belt CurrentBelt

@Suite("BeltManager - CurrentBelt") @MainActor
struct BeltManagerCurrentBeltTests {

    func makeManager() -> BeltManager {
        BeltManager(services: MockBeltServices(), logger: nil)
    }

    @Test("currentBelt returns nil when history is empty")
    func currentBeltEmpty() {
        // GIVEN
        let manager = makeManager()

        // WHEN / THEN
        #expect(manager.currentBelt == nil)
    }

    @Test("currentBeltEnum returns white when history is empty")
    func currentBeltEnumDefault() {
        // GIVEN
        let manager = makeManager()

        // WHEN / THEN
        #expect(manager.currentBeltEnum == .white)
    }

    @Test("currentBelt returns the highest belt record")
    func currentBeltHighest() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .white, stripes: 4)
        try manager.addPromotion(belt: .blue, stripes: 0)

        // WHEN
        let current = manager.currentBelt

        // THEN
        #expect(current?.belt == .blue)
    }

    @Test("currentBeltEnum matches the belt of the highest record")
    func currentBeltEnumValue() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .white)
        try manager.addPromotion(belt: .purple, stripes: 1)

        // WHEN / THEN
        #expect(manager.currentBeltEnum == .purple)
    }

    @Test("currentBelt uses stripes as a tiebreaker within the same belt")
    func currentBeltStripesTiebreaker() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .blue, stripes: 1)
        try manager.addPromotion(belt: .blue, stripes: 3)

        // WHEN
        let current = manager.currentBelt

        // THEN
        #expect(current?.stripes == 3)
    }

    @Test("currentBelt ranks a higher belt over same-belt with more stripes")
    func currentBeltHigherBeltWinsOverStripes() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .white, stripes: 4)
        try manager.addPromotion(belt: .blue, stripes: 0)   // blue, 0 stripes

        // WHEN
        let current = manager.currentBelt

        // THEN — blue with 0 stripes ranks higher than white with 4 stripes
        #expect(current?.belt == .blue)
    }
}

// MARK: - Belt EstimatedTime

@Suite("BeltManager - EstimatedTime") @MainActor
struct BeltManagerEstimatedTimeTests {

    func makeManager() -> BeltManager {
        BeltManager(services: MockBeltServices(), logger: nil)
    }

    @Test("estimatedTimeToNextBelt returns nil for black belt")
    func noEstimateForBlackBelt() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .black)

        // WHEN
        let estimate = manager.estimatedTimeToNextBelt()

        // THEN
        #expect(estimate == nil)
    }

    @Test("estimatedTimeToNextBelt returns a value for an empty history (defaults to white belt)")
    func estimateForNoBelt() {
        // GIVEN — no belt history; currentBeltEnum defaults to .white
        let manager = makeManager()

        // WHEN
        let estimate = manager.estimatedTimeToNextBelt(sessionsPerWeek: 3)

        // THEN — white belt has a 2.0-year estimate to blue
        #expect(estimate == "2.0 years")
    }

    @Test("estimatedTimeToNextBelt returns a years string at 3 sessions per week")
    func estimateAtThreeSessionsPerWeek() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .white)  // typical 2.0 years at 3/wk

        // WHEN
        let estimate = manager.estimatedTimeToNextBelt(sessionsPerWeek: 3)

        // THEN
        #expect(estimate == "2.0 years")
    }

    @Test("estimatedTimeToNextBelt returns months when adjusted time is less than 1 year")
    func estimateInMonths() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .white)  // 2.0 years at 3/wk → ~6 months at 12/wk

        // WHEN
        let estimate = manager.estimatedTimeToNextBelt(sessionsPerWeek: 12)

        // THEN
        #expect(estimate?.contains("months") == true)
    }

    @Test("estimatedTimeToNextBelt increases estimate for fewer sessions per week")
    func estimateScalesWithSessionFrequency() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .blue)  // 3.0 years at 3/wk

        // WHEN
        let at3 = manager.estimatedTimeToNextBelt(sessionsPerWeek: 3)
        let at1 = manager.estimatedTimeToNextBelt(sessionsPerWeek: 1)

        // THEN — training less often = longer estimate
        #expect(at3 != nil)
        #expect(at1 != nil)
        // at 1/wk should be "9.0 years", at 3/wk should be "3.0 years"
        #expect(at3 == "3.0 years")
        #expect(at1 == "9.0 years")
    }
}

// MARK: - Belt Lifecycle

@Suite("BeltManager - Lifecycle") @MainActor
struct BeltManagerLifecycleTests {

    func makeManager() -> BeltManager {
        BeltManager(services: MockBeltServices(), logger: nil)
    }

    @Test("clearAll removes all belt history")
    func clearAll() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .white)
        try manager.addPromotion(belt: .blue)
        #expect(manager.beltHistory.count == 2)

        // WHEN
        manager.clearAll()

        // THEN
        #expect(manager.beltHistory.isEmpty)
    }

    @Test("seedMockDataIfEmpty populates history when the manager is empty")
    func seedMockDataIfEmpty() {
        // GIVEN
        let manager = makeManager()
        #expect(manager.beltHistory.isEmpty)

        // WHEN
        manager.seedMockDataIfEmpty()

        // THEN
        #expect(!manager.beltHistory.isEmpty)
    }

    @Test("seedMockDataIfEmpty does not overwrite existing history")
    func seedMockDataDoesNotOverwrite() throws {
        // GIVEN
        let manager = makeManager()
        try manager.addPromotion(belt: .brown, stripes: 2)
        let countBefore = manager.beltHistory.count

        // WHEN
        manager.seedMockDataIfEmpty()

        // THEN
        #expect(manager.beltHistory.count == countBefore)
        #expect(manager.beltHistory.first?.belt == .brown)
    }
}
