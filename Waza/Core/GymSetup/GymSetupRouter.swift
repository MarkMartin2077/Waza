import SwiftUI

@MainActor
protocol GymSetupRouter: GlobalRouter { }

extension CoreRouter: GymSetupRouter { }
