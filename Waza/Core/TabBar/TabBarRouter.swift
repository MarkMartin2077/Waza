import SwiftUI
import SwiftfulRouting

@MainActor
protocol TabBarRouter: GlobalRouter {
    func showAchievementModal(achievementId: AchievementId, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void)
    func showLevelUpModal(level: Int, title: String, xpGained: Int, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void)
    func showFireRoundModal(onDismiss: @escaping @MainActor @Sendable () -> Void)
    func showStreakTierUpModal(tier: StreakTier, accentColor: Color, onDismiss: @escaping @MainActor @Sendable () -> Void)
    func dismissCelebrationModal()
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?)
    func showTechniquePromotion(
        data: TechniquePromotionData,
        onPromote: @escaping @MainActor @Sendable () -> Void,
        onSnooze: @escaping @MainActor @Sendable () -> Void,
        onDismissPressed: @escaping @MainActor @Sendable () -> Void,
        onSheetDismissed: @escaping @MainActor @Sendable () -> Void
    )
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

    func showTechniquePromotion(
        data: TechniquePromotionData,
        onPromote: @escaping @MainActor @Sendable () -> Void,
        onSnooze: @escaping @MainActor @Sendable () -> Void,
        onDismissPressed: @escaping @MainActor @Sendable () -> Void,
        onSheetDismissed: @escaping @MainActor @Sendable () -> Void
    ) {
        let config = ResizableSheetConfig(
            detents: [.medium],
            selection: nil,
            dragIndicator: .visible
        )
        router.showScreen(.sheetConfig(config: config), onDismiss: onSheetDismissed) { _ in
            TechniquePromotionPromptView(
                techniqueName: data.techniqueName,
                currentStage: data.currentStage,
                suggestedStage: data.suggestedStage,
                practiceCount: data.practiceCount,
                onPromote: onPromote,
                onSnooze: onSnooze,
                onDismiss: onDismissPressed
            )
        }
    }
}
