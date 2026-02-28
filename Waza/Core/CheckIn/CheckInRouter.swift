import SwiftUI

@MainActor
protocol CheckInRouter: GlobalRouter {
    func showSessionEntryView(onDismiss: (() -> Void)?)
}

extension CoreRouter: CheckInRouter { }
