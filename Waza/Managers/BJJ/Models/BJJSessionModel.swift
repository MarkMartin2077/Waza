import Foundation
import IdentifiableByString

struct BJJSessionModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var sessionId: String
    var date: Date
    var duration: TimeInterval
    var sessionType: SessionType
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

    var id: String { sessionId }

    init(
        sessionId: String = UUID().uuidString,
        date: Date = Date(),
        duration: TimeInterval = 5400,
        sessionType: SessionType = .gi,
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
        self.sessionType = sessionType
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

    init(entity: BJJSessionEntity) {
        self.sessionId = entity.sessionId
        self.date = entity.date
        self.duration = entity.duration
        self.sessionType = SessionType(rawValue: entity.sessionTypeRaw) ?? .gi
        self.academy = entity.academy
        self.instructor = entity.instructor
        self.focusAreas = entity.focusAreas
        self.techniquesWorked = entity.techniquesWorked
        self.notes = entity.notes
        self.preSessionMood = entity.preSessionMood
        self.postSessionMood = entity.postSessionMood
        self.roundsCount = entity.roundsCount
        self.whatWorkedWell = entity.whatWorkedWell
        self.needsImprovement = entity.needsImprovement
        self.keyInsights = entity.keyInsights
    }

    func toEntity() -> BJJSessionEntity {
        BJJSessionEntity(from: self)
    }

    // MARK: - Computed Display Properties

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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case date
        case duration
        case sessionType = "session_type"
        case academy
        case instructor
        case focusAreas = "focus_areas"
        case techniquesWorked = "techniques_worked"
        case notes
        case preSessionMood = "pre_session_mood"
        case postSessionMood = "post_session_mood"
        case roundsCount = "rounds_count"
        case whatWorkedWell = "what_worked_well"
        case needsImprovement = "needs_improvement"
        case keyInsights = "key_insights"
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "session_id": sessionId,
            "session_type": sessionType.rawValue,
            "duration": duration,
            "rounds_count": roundsCount,
            "techniques_worked_count": techniquesWorked.count
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension BJJSessionModel {
    static var mock: BJJSessionModel {
        BJJSessionModel(
            sessionId: "mock-session-1",
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
        let cal = Calendar.current
        let now = Date()
        return [
            // This week
            mock,
            BJJSessionModel(
                sessionId: "mock-session-2",
                date: cal.date(byAdding: .day, value: -3, to: now) ?? now,
                duration: 3600,
                sessionType: .noGi,
                academy: "Gracie Barra",
                focusAreas: ["Takedowns", "Wrestling"],
                notes: "Worked on shot defense and level changes.",
                preSessionMood: 3,
                postSessionMood: 4,
                roundsCount: 4
            ),
            BJJSessionModel(
                sessionId: "mock-session-3",
                date: cal.date(byAdding: .day, value: -5, to: now) ?? now,
                duration: 7200,
                sessionType: .openMat,
                academy: "10th Planet",
                focusAreas: ["Free Rolling"],
                notes: "Open mat — lots of rounds with various partners.",
                preSessionMood: 4,
                postSessionMood: 5,
                roundsCount: 8
            ),
            // Last week
            BJJSessionModel(
                sessionId: "mock-session-4",
                date: cal.date(byAdding: .day, value: -9, to: now) ?? now,
                duration: 4800,
                sessionType: .drilling,
                academy: "Gracie Barra",
                focusAreas: ["Triangle", "Armbar"],
                notes: "Drilling fundamentals. Triangle from closed guard.",
                preSessionMood: 3,
                postSessionMood: 3,
                roundsCount: 0
            ),
            BJJSessionModel(
                sessionId: "mock-session-5",
                date: cal.date(byAdding: .day, value: -12, to: now) ?? now,
                duration: 5400,
                sessionType: .gi,
                academy: "Alliance",
                focusAreas: ["Guard Retention", "Sweeps"],
                notes: "Focused on retaining guard under pressure.",
                preSessionMood: 2,
                postSessionMood: 4,
                roundsCount: 6
            ),
            // Last month
            BJJSessionModel(
                sessionId: "mock-session-6",
                date: cal.date(byAdding: .day, value: -35, to: now) ?? now,
                duration: 3600,
                sessionType: .competition,
                academy: nil,
                focusAreas: ["Competition Prep", "Passing"],
                notes: "Local tournament. Won two matches by points.",
                preSessionMood: 5,
                postSessionMood: 5,
                roundsCount: 4,
                whatWorkedWell: "Pressure passing worked great under stress",
                keyInsights: "Stay calm in the first 30 seconds"
            ),
            BJJSessionModel(
                sessionId: "mock-session-7",
                date: cal.date(byAdding: .day, value: -40, to: now) ?? now,
                duration: 3600,
                sessionType: .privateLesson,
                academy: "Gracie Barra",
                instructor: "Professor Silva",
                focusAreas: ["Half Guard", "Underhooks"],
                notes: "Private with Professor Silva on half guard game.",
                preSessionMood: 4,
                postSessionMood: 5,
                roundsCount: 0,
                whatWorkedWell: "Knee shield to underhook transition",
                needsImprovement: "Pummeling speed"
            ),
            // Two months ago
            BJJSessionModel(
                sessionId: "mock-session-8",
                date: cal.date(byAdding: .day, value: -65, to: now) ?? now,
                duration: 5400,
                sessionType: .noGi,
                academy: "10th Planet",
                focusAreas: ["Leg Locks", "Heel Hook"],
                notes: "No-gi leg lock seminar. Inside heel hook mechanics.",
                preSessionMood: 4,
                postSessionMood: 5,
                roundsCount: 3
            ),
            BJJSessionModel(
                sessionId: "mock-session-9",
                date: cal.date(byAdding: .day, value: -70, to: now) ?? now,
                duration: 5400,
                sessionType: .gi,
                academy: "Gracie Barra",
                focusAreas: ["Back Takes", "Chokes"],
                notes: "Bow and arrow choke from back control.",
                preSessionMood: 1,
                postSessionMood: 3,
                roundsCount: 5,
                needsImprovement: "Seatbelt grip was slipping"
            )
        ]
    }
}
