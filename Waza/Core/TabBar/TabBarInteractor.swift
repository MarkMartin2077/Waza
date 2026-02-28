import SwiftUI

@MainActor
protocol TabBarInteractor: GlobalInteractor {
    var currentBeltAccentColor: Color { get }
}

extension CoreInteractor: TabBarInteractor {
    var currentBeltAccentColor: Color {
        currentBeltEnum.accentColor
    }
}
