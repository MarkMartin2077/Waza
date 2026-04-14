import Testing
import Foundation
@testable import Waza

// MARK: - Helpers

@MainActor
private func makeManager() -> TechniqueManager {
    TechniqueManager(services: MockTechniqueServices())
}

// MARK: - CRUD

@Suite("TechniqueManager - CRUD") @MainActor
struct TechniqueManagerCRUDTests {

    @Test("Creating a technique adds it to the techniques array")
    func createAddsTechnique() throws {
        let manager = makeManager()
        #expect(manager.techniques.isEmpty)

        let technique = try manager.createTechnique(name: "Triangle", category: .submissions)

        #expect(manager.techniques.count == 1)
        #expect(manager.techniques.first?.name == "Triangle")
        #expect(manager.techniques.first?.category == .submissions)
        #expect(manager.techniques.first?.stage == .learning)
        #expect(technique.techniqueId == manager.techniques.first?.techniqueId)
    }

    @Test("Updating a technique persists the changes")
    func updatePersists() throws {
        let manager = makeManager()
        var technique = try manager.createTechnique(name: "Armbar", category: .submissions)

        technique.stage = .applying
        technique.notes = "Tight from guard"
        try manager.updateTechnique(technique)

        let reloaded = manager.techniques.first { $0.techniqueId == technique.techniqueId }
        #expect(reloaded?.stage == .applying)
        #expect(reloaded?.notes == "Tight from guard")
    }

    @Test("Deleting a technique removes it")
    func deleteRemoves() throws {
        let manager = makeManager()
        let technique = try manager.createTechnique(name: "Guard Pass")
        #expect(manager.techniques.count == 1)

        try manager.deleteTechnique(technique)

        #expect(manager.techniques.isEmpty)
    }

    @Test("clearAll empties the techniques array")
    func clearAllEmpties() throws {
        let manager = makeManager()
        try manager.createTechnique(name: "A")
        try manager.createTechnique(name: "B")
        #expect(manager.techniques.count == 2)

        manager.clearAll()

        #expect(manager.techniques.isEmpty)
    }
}

// MARK: - ensureTechniquesExist

@Suite("TechniqueManager - ensureTechniquesExist") @MainActor
struct TechniqueManagerEnsureTests {

    @Test("Creates techniques for new focus areas")
    func createsForNewAreas() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Triangle", "Guard Passing"])

        #expect(manager.techniques.count == 2)
        let names = Set(manager.techniques.map { $0.name })
        #expect(names == ["Triangle", "Guard Passing"])
    }

    @Test("Does not create duplicates for exact matches")
    func noDuplicateExactMatch() throws {
        let manager = makeManager()
        try manager.createTechnique(name: "Triangle")

        manager.ensureTechniquesExist(for: ["Triangle"])

        #expect(manager.techniques.count == 1)
    }

    @Test("Dedup is case-insensitive")
    func caseInsensitiveDedup() throws {
        let manager = makeManager()
        try manager.createTechnique(name: "Triangle")

        manager.ensureTechniquesExist(for: ["triangle", "TRIANGLE", "Triangle"])

        #expect(manager.techniques.count == 1)
    }

    @Test("Infers submissions category for a triangle")
    func infersSubmissions() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Triangle"])

        #expect(manager.techniques.first?.category == .submissions)
    }

    @Test("Infers passing category for 'Guard Passing'")
    func infersPassing() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Guard Passing"])

        #expect(manager.techniques.first?.category == .passing)
    }

    @Test("Infers guard category for 'Closed Guard'")
    func infersGuard() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Closed Guard"])

        #expect(manager.techniques.first?.category == .guardPlay)
    }

    @Test("Infers takedowns category from 'Takedowns' and 'Wrestling'")
    func infersTakedowns() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Takedowns", "Wrestling"])

        for technique in manager.techniques {
            #expect(technique.category == .takedowns)
        }
    }

    @Test("Falls back to uncategorized for unrecognized names")
    func fallsBackToUncategorized() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Mystery Technique"])

        #expect(manager.techniques.first?.category == .uncategorized)
    }

    @Test("All created techniques start at the learning stage")
    func allStartAtLearning() {
        let manager = makeManager()

        manager.ensureTechniquesExist(for: ["Triangle", "Armbar", "Back Take"])

        for technique in manager.techniques {
            #expect(technique.stage == .learning)
        }
    }

    @Test("Mix of new and existing names only creates the missing ones")
    func mixedCreatesOnlyMissing() throws {
        let manager = makeManager()
        try manager.createTechnique(name: "Triangle")

        manager.ensureTechniquesExist(for: ["Triangle", "Armbar", "Kimura"])

        #expect(manager.techniques.count == 3)
        let names = Set(manager.techniques.map { $0.name.lowercased() })
        #expect(names.contains("triangle"))
        #expect(names.contains("armbar"))
        #expect(names.contains("kimura"))
    }
}

// MARK: - Category Inference (Pure Logic)

@Suite("TechniqueCategory - Inference")
struct TechniqueCategoryInferenceTests {

    @Test("Triangle -> submissions")
    func triangleIsSubmission() {
        #expect(TechniqueCategory.infer(from: "Triangle") == .submissions)
    }

    @Test("Armbar -> submissions")
    func armbarIsSubmission() {
        #expect(TechniqueCategory.infer(from: "Armbar") == .submissions)
    }

    @Test("Bow and arrow choke -> submissions")
    func chokeIsSubmission() {
        #expect(TechniqueCategory.infer(from: "Bow and Arrow Choke") == .submissions)
    }

    @Test("Heel hook -> submissions")
    func heelHookIsSubmission() {
        #expect(TechniqueCategory.infer(from: "Heel Hook") == .submissions)
    }

    @Test("Guard passing -> passing (pass wins over guard)")
    func guardPassIsPassing() {
        #expect(TechniqueCategory.infer(from: "Guard Passing") == .passing)
    }

    @Test("Torreando Pass -> passing")
    func torreandoIsPassing() {
        #expect(TechniqueCategory.infer(from: "Torreando Pass") == .passing)
    }

    @Test("Closed Guard -> guard")
    func closedGuardIsGuard() {
        #expect(TechniqueCategory.infer(from: "Closed Guard") == .guardPlay)
    }

    @Test("Takedown -> takedowns")
    func takedownIsTakedowns() {
        #expect(TechniqueCategory.infer(from: "Double Leg Takedown") == .takedowns)
    }

    @Test("Wrestling -> takedowns")
    func wrestlingIsTakedowns() {
        #expect(TechniqueCategory.infer(from: "Wrestling") == .takedowns)
    }

    @Test("Scissor sweep -> sweeps")
    func sweepIsSweeps() {
        #expect(TechniqueCategory.infer(from: "Scissor Sweep") == .sweeps)
    }

    @Test("Mount escape -> escapes")
    func escapeIsEscapes() {
        #expect(TechniqueCategory.infer(from: "Mount Escape") == .escapes)
    }

    @Test("Unknown name -> uncategorized")
    func unknownIsUncategorized() {
        #expect(TechniqueCategory.infer(from: "Nonsense Move 123") == .uncategorized)
    }

    @Test("Case insensitive matching")
    func caseInsensitive() {
        #expect(TechniqueCategory.infer(from: "TRIANGLE") == .submissions)
        #expect(TechniqueCategory.infer(from: "triangle") == .submissions)
    }
}

// MARK: - setStage

@Suite("TechniqueManager - setStage") @MainActor
struct TechniqueManagerSetStageTests {

    @Test("setStage transitions stage and stamps lastStageChangeDate")
    func setStageStampsDate() throws {
        let manager = makeManager()
        let technique = try manager.createTechnique(name: "Triangle", stage: .learning)
        #expect(technique.lastStageChangeDate == nil)

        let before = Date()
        let promoted = try manager.setStage(.drilling, on: technique)

        #expect(promoted.stage == .drilling)
        #expect(promoted.lastStageChangeDate != nil)
        if let changed = promoted.lastStageChangeDate {
            #expect(changed >= before)
        }
    }

    @Test("setStage with same stage is a no-op (no date stamped)")
    func setStageSameStageIsNoOp() throws {
        let manager = makeManager()
        let technique = try manager.createTechnique(name: "Triangle", stage: .learning)

        let result = try manager.setStage(.learning, on: technique)

        #expect(result.lastStageChangeDate == nil)
        #expect(result.stage == .learning)
    }

    @Test("setStage persists the change — reload confirms")
    func setStagePersists() throws {
        let manager = makeManager()
        let technique = try manager.createTechnique(name: "Triangle", stage: .learning)

        _ = try manager.setStage(.applying, on: technique)

        let reloaded = manager.techniques.first { $0.techniqueId == technique.techniqueId }
        #expect(reloaded?.stage == .applying)
        #expect(reloaded?.lastStageChangeDate != nil)
    }
}

// MARK: - Lifecycle

@Suite("TechniqueManager - Lifecycle") @MainActor
struct TechniqueManagerLifecycleTests {

    @Test("seedMockDataIfEmpty populates when empty")
    func seedPopulatesWhenEmpty() {
        let manager = makeManager()
        #expect(manager.techniques.isEmpty)

        manager.seedMockDataIfEmpty()

        #expect(!manager.techniques.isEmpty)
    }

    @Test("seedMockDataIfEmpty does not overwrite existing techniques")
    func seedDoesNotOverwrite() throws {
        let manager = makeManager()
        try manager.createTechnique(name: "Pre-existing")
        let originalCount = manager.techniques.count

        manager.seedMockDataIfEmpty()

        #expect(manager.techniques.count == originalCount)
        #expect(manager.techniques.contains { $0.name == "Pre-existing" })
    }
}
