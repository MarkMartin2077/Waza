import SwiftUI

@MainActor
protocol TrainingStatsRouter: GlobalRouter { }

extension CoreRouter: TrainingStatsRouter { }
