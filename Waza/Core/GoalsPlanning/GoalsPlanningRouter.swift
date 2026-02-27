import SwiftUI

@MainActor
protocol GoalsPlanningRouter: GlobalRouter { }

extension CoreRouter: GoalsPlanningRouter { }
