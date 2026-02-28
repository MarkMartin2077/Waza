import SwiftUI

@MainActor
protocol AchievementsRouter: GlobalRouter { }

extension CoreRouter: AchievementsRouter { }
