import SwiftUI

@MainActor
protocol SessionsInteractor: GlobalInteractor {
    var allSessions: [BJJSessionModel] { get }
}

extension CoreInteractor: SessionsInteractor { }
