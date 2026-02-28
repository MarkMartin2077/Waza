import Foundation

struct CLAGameLibrary {
    static let allGames: [CLAGameModel] =
        guardRetentionGames +
        guardPassingGames +
        escapeGames +
        submissionGames +
        takedownGames +
        positionalGames
}
