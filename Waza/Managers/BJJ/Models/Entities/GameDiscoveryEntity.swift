import SwiftData
import Foundation

@Model
final class GameDiscoveryEntity {
    @Attribute(.unique) var discoveryId: String
    var date: Date
    var text: String
    var successRating: Int
    var sessionId: String?
    var gameId: String

    init(
        discoveryId: String,
        date: Date,
        text: String,
        successRating: Int,
        sessionId: String?,
        gameId: String
    ) {
        self.discoveryId = discoveryId
        self.date = date
        self.text = text
        self.successRating = successRating
        self.sessionId = sessionId
        self.gameId = gameId
    }

    convenience init(from model: GameDiscoveryModel) {
        self.init(
            discoveryId: model.discoveryId,
            date: model.date,
            text: model.text,
            successRating: model.successRating,
            sessionId: model.sessionId,
            gameId: model.gameId
        )
    }

    func toModel() -> GameDiscoveryModel {
        GameDiscoveryModel(entity: self)
    }
}
