import Foundation

struct GameDiscoveryModel: Codable, Sendable, Identifiable {
    var discoveryId: String
    var date: Date
    var text: String
    var successRating: Int
    var sessionId: String?
    var gameId: String

    var id: String { discoveryId }

    init(
        discoveryId: String = UUID().uuidString,
        date: Date = Date(),
        text: String,
        successRating: Int = 3,
        sessionId: String? = nil,
        gameId: String
    ) {
        self.discoveryId = discoveryId
        self.date = date
        self.text = text
        self.successRating = successRating
        self.sessionId = sessionId
        self.gameId = gameId
    }

    init(entity: GameDiscoveryEntity) {
        self.discoveryId = entity.discoveryId
        self.date = entity.date
        self.text = entity.text
        self.successRating = entity.successRating
        self.sessionId = entity.sessionId
        self.gameId = entity.gameId
    }

    func toEntity() -> GameDiscoveryEntity {
        GameDiscoveryEntity(from: self)
    }

    enum CodingKeys: String, CodingKey {
        case discoveryId = "discovery_id"
        case date
        case text
        case successRating = "success_rating"
        case sessionId = "session_id"
        case gameId = "game_id"
    }

    var eventParameters: [String: Any] {
        var dict: [String: Any] = [
            "discovery_id": discoveryId,
            "game_id": gameId,
            "success_rating": successRating
        ]
        if let sessionId { dict["session_id"] = sessionId }
        return dict
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    static var mock: GameDiscoveryModel {
        GameDiscoveryModel(
            text: "I noticed that keeping my elbow tight to my body prevents the escape",
            successRating: 4,
            gameId: "builtin-gr-01"
        )
    }
}
