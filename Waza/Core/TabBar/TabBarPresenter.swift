import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    private let interactor: TabBarInteractor

    var pendingUnlockAchievement: AchievementId?

    init(interactor: TabBarInteractor) {
        self.interactor = interactor
    }

    var beltAccentColor: Color {
        interactor.currentBeltAccentColor
    }

    func onAchievementUnlocked(_ id: AchievementId) {
        // Only show if nothing already queued (first one wins)
        guard pendingUnlockAchievement == nil else { return }
        Task { @MainActor in
            // The notification fires before router.dismissScreen() is called, so the
            // presenting sheet may still be animating closed (~300ms). Wait 0.6s to
            // ensure the sheet is fully dismissed before the achievement modal appears.
            try? await Task.sleep(nanoseconds: 600_000_000)
            withAnimation(.easeIn(duration: 0.2)) {
                pendingUnlockAchievement = id
            }
            interactor.playHaptic(option: .heavy)
            try? await Task.sleep(nanoseconds: 150_000_000)
            interactor.playHaptic(option: .heavy)
            try? await Task.sleep(nanoseconds: 250_000_000)
            interactor.playHaptic(option: .success)
        }
    }

    func onAchievementDismissed() {
        withAnimation(.easeOut(duration: 0.2)) {
            pendingUnlockAchievement = nil
        }
    }
}
