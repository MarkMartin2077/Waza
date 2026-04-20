import SwiftData
import Foundation

@Model
final class BJJSessionEntity {
    @Attribute(.unique) var sessionId: String
    var date: Date
    var duration: TimeInterval
    var sessionTypeRaw: String
    var academy: String?
    var instructor: String?
    var focusAreas: [String]
    var techniquesWorked: [String]
    var notes: String?
    var preSessionMood: Int?
    var postSessionMood: Int?
    var roundsCount: Int
    var whatWorkedWell: String?
    var needsImprovement: String?
    var keyInsights: String?

    init(
        sessionId: String = UUID().uuidString,
        date: Date = Date(),
        duration: TimeInterval = 5400,
        sessionTypeRaw: String = "gi",
        academy: String? = nil,
        instructor: String? = nil,
        focusAreas: [String] = [],
        techniquesWorked: [String] = [],
        notes: String? = nil,
        preSessionMood: Int? = nil,
        postSessionMood: Int? = nil,
        roundsCount: Int = 0,
        whatWorkedWell: String? = nil,
        needsImprovement: String? = nil,
        keyInsights: String? = nil
    ) {
        self.sessionId = sessionId
        self.date = date
        self.duration = duration
        self.sessionTypeRaw = sessionTypeRaw
        self.academy = academy
        self.instructor = instructor
        self.focusAreas = focusAreas
        self.techniquesWorked = techniquesWorked
        self.notes = notes
        self.preSessionMood = preSessionMood
        self.postSessionMood = postSessionMood
        self.roundsCount = roundsCount
        self.whatWorkedWell = whatWorkedWell
        self.needsImprovement = needsImprovement
        self.keyInsights = keyInsights
    }

    convenience init(from model: BJJSessionModel) {
        self.init(
            sessionId: model.sessionId,
            date: model.date,
            duration: model.duration,
            sessionTypeRaw: model.sessionType.rawValue,
            academy: model.academy,
            instructor: model.instructor,
            focusAreas: model.focusAreas,
            techniquesWorked: model.techniquesWorked,
            notes: model.notes,
            preSessionMood: model.preSessionMood,
            postSessionMood: model.postSessionMood,
            roundsCount: model.roundsCount,
            whatWorkedWell: model.whatWorkedWell,
            needsImprovement: model.needsImprovement,
            keyInsights: model.keyInsights
        )
    }

    func toModel() -> BJJSessionModel {
        BJJSessionModel(
            sessionId: sessionId,
            date: date,
            duration: duration,
            sessionType: SessionType(rawValue: sessionTypeRaw) ?? .gi,
            academy: academy,
            instructor: instructor,
            focusAreas: focusAreas,
            techniquesWorked: techniquesWorked,
            notes: notes,
            preSessionMood: preSessionMood,
            postSessionMood: postSessionMood,
            roundsCount: roundsCount,
            whatWorkedWell: whatWorkedWell,
            needsImprovement: needsImprovement,
            keyInsights: keyInsights
        )
    }

    func update(from model: BJJSessionModel) {
        date = model.date
        duration = model.duration
        sessionTypeRaw = model.sessionType.rawValue
        academy = model.academy
        instructor = model.instructor
        focusAreas = model.focusAreas
        techniquesWorked = model.techniquesWorked
        notes = model.notes
        preSessionMood = model.preSessionMood
        postSessionMood = model.postSessionMood
        roundsCount = model.roundsCount
        whatWorkedWell = model.whatWorkedWell
        needsImprovement = model.needsImprovement
        keyInsights = model.keyInsights
    }
}
