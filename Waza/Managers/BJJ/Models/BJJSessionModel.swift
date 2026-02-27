import SwiftData
import Foundation

@Model
final class BJJSessionModel {
    @Attribute(.unique) var id: String
    var date: Date
    var duration: TimeInterval
    var sessionTypeRaw: String
    var academy: String?
    var instructor: String?
    var focusAreas: [String]
    var notes: String?
    var preSessionMood: Int?
    var postSessionMood: Int?
    var roundsCount: Int
    var whatWorkedWell: String?
    var needsImprovement: String?
    var keyInsights: String?

    var sessionType: SessionType {
        get { SessionType(rawValue: sessionTypeRaw) ?? .gi }
        set { sessionTypeRaw = newValue.rawValue }
    }

    var durationFormatted: String {
        let totalMinutes = Int(duration) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        duration: TimeInterval = 5400,
        sessionType: SessionType = .gi,
        academy: String? = nil,
        instructor: String? = nil,
        focusAreas: [String] = [],
        notes: String? = nil,
        preSessionMood: Int? = nil,
        postSessionMood: Int? = nil,
        roundsCount: Int = 0,
        whatWorkedWell: String? = nil,
        needsImprovement: String? = nil,
        keyInsights: String? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.sessionTypeRaw = sessionType.rawValue
        self.academy = academy
        self.instructor = instructor
        self.focusAreas = focusAreas
        self.notes = notes
        self.preSessionMood = preSessionMood
        self.postSessionMood = postSessionMood
        self.roundsCount = roundsCount
        self.whatWorkedWell = whatWorkedWell
        self.needsImprovement = needsImprovement
        self.keyInsights = keyInsights
    }
}

extension BJJSessionModel {
    static var mock: BJJSessionModel {
        BJJSessionModel(
            id: "mock-session-1",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            duration: 5400,
            sessionType: .gi,
            academy: "Gracie Barra",
            instructor: "Professor Silva",
            focusAreas: ["Guard Passing", "Back Takes"],
            notes: "Great drilling session. Really clicked on the leg drag today.",
            preSessionMood: 4,
            postSessionMood: 5,
            roundsCount: 5,
            whatWorkedWell: "Leg drag to back take combination",
            needsImprovement: "Defending the kimura from top",
            keyInsights: "Hip angle is key for the leg drag"
        )
    }

    static var mocks: [BJJSessionModel] {
        [
            mock,
            BJJSessionModel(
                id: "mock-session-2",
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                duration: 3600,
                sessionType: .noGi,
                academy: "Gracie Barra",
                focusAreas: ["Takedowns", "Wrestling"],
                notes: "Worked on shot defense and level changes.",
                roundsCount: 4
            ),
            BJJSessionModel(
                id: "mock-session-3",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                duration: 7200,
                sessionType: .openMat,
                focusAreas: ["Free Rolling"],
                notes: "Open mat — lots of rounds with various partners.",
                roundsCount: 8
            ),
            BJJSessionModel(
                id: "mock-session-4",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                duration: 4800,
                sessionType: .drilling,
                focusAreas: ["Triangle", "Armbar"],
                notes: "Drilling fundamentals. Triangle from closed guard.",
                roundsCount: 0
            )
        ]
    }
}
