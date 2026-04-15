import SwiftUI

@MainActor
protocol TabBarRouter: GlobalRouter {
    func showAchievementModal(achievementId: AchievementId, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void)
    func showLevelUpModal(level: Int, title: String, xpGained: Int, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void)
    func showFireRoundModal(onDismiss: @escaping @MainActor @Sendable () -> Void)
    func showStreakTierUpModal(tier: StreakTier, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void)
    func dismissCelebrationModal()
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?)
}

extension CoreRouter: TabBarRouter {

    func showAchievementModal(achievementId: AchievementId, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void) {
        router.showModal(transition: .opacity, animation: .easeIn(duration: 0.2), backgroundColor: nil, dismissOnBackgroundTap: false, ignoreSafeArea: true) {
            AchievementUnlockModal(
                achievementId: achievementId,
                accentColor: accentColor,
                onDismiss: onDismiss
            )
        }
    }

    func showLevelUpModal(level: Int, title: String, xpGained: Int, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void) {
        router.showModal(transition: .opacity, animation: .easeIn(duration: 0.2), backgroundColor: nil, dismissOnBackgroundTap: false, ignoreSafeArea: true) {
            LevelUpModal(
                level: level,
                title: title,
                xpGained: xpGained,
                accentColor: accentColor,
                onDismiss: onDismiss
            )
        }
    }

    func showFireRoundModal(onDismiss: @escaping @MainActor @Sendable () -> Void) {
        router.showModal(transition: .opacity, animation: .easeIn(duration: 0.2), backgroundColor: nil, dismissOnBackgroundTap: false, ignoreSafeArea: true) {
            FireRoundModal(onDismiss: onDismiss)
        }
    }

    func showStreakTierUpModal(tier: StreakTier, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void) {
        router.showModal(transition: .opacity, animation: .easeIn(duration: 0.2), backgroundColor: nil, dismissOnBackgroundTap: false, ignoreSafeArea: true) {
            StreakTierUpModal(
                tier: tier,
                accentColor: accentColor,
                onDismiss: onDismiss
            )
        }
    }

    func dismissCelebrationModal() {
        router.dismissModal()
    }
}
