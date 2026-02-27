import SwiftUI

@MainActor
protocol SessionDetailRouter: GlobalRouter { }

extension CoreRouter: SessionDetailRouter { }
