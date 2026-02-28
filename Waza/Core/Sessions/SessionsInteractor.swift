import SwiftUI

@MainActor
protocol SessionsInteractor: GlobalInteractor {
    var currentBeltEnum: BJJBelt { get }
    var allSessions: [BJJSessionModel] { get }
}

extension CoreInteractor: SessionsInteractor { }
