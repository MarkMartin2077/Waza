import SwiftUI

@MainActor
protocol OnboardingRouter: GlobalRouter {
    func switchToCoreModule()
}

extension CoreRouter: OnboardingRouter { }
