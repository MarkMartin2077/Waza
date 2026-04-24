import SwiftUI

@MainActor
protocol TrainInteractor: GlobalInteractor {
}

extension CoreInteractor: TrainInteractor { }
