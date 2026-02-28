import SwiftUI

@MainActor
protocol AIInsightsRouter: GlobalRouter { }

extension CoreRouter: AIInsightsRouter { }
