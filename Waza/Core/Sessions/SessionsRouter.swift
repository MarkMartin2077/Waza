import SwiftUI

@MainActor
protocol SessionsRouter: GlobalRouter {
    func showSessionDetailView(session: BJJSessionModel)
    func showSessionEntryView(onDismiss: (() -> Void)?)
}

extension CoreRouter: SessionsRouter { }
