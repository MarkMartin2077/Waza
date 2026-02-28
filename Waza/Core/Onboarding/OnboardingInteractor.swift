import SwiftUI

@MainActor
protocol OnboardingInteractor: GlobalInteractor {
    func setInitialBelt(belt: BJJBelt, stripes: Int, date: Date, academy: String?, notes: String?) throws
    func markOnboardingComplete() async throws
    @discardableResult
    func requestPushAuthorization() async throws -> Bool
    func requestLocationAuthorization()
}

extension CoreInteractor: OnboardingInteractor { }
