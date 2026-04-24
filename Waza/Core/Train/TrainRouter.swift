import SwiftUI

@MainActor
protocol TrainRouter: GlobalRouter {
    func showSessionEntryView(onDismiss: (() -> Void)?)
}

extension CoreRouter: TrainRouter { }
