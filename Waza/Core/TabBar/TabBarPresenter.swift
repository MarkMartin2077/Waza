import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    private let interactor: TabBarInteractor

    init(interactor: TabBarInteractor) {
        self.interactor = interactor
    }

    var beltAccentColor: Color {
        interactor.currentBeltAccentColor
    }
}
