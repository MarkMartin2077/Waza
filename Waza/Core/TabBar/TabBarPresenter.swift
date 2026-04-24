import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    private let interactor: TabBarInteractor
    private let router: TabBarRouter

    private var unlockQueue: [AchievementId] = []
    private var xpQueue: [XPToastData] = []
    private var isCelebrationShowing: Bool = false

    private var isShowingCheckIn: Bool = false
    var pendingXPToast: XPToastData?
    var pendingChallengeToast: String?

    init(interactor: TabBarInteractor, router: TabBarRouter) {
        self.interactor = interactor
        self.router = router
    }

    var beltAccentColor: Color {
        .wazaAccent
    }

    // MARK: - Observable Signals

    var lastUnlockedAchievement: AchievementId? {
        interactor.lastUnlockedAchievement
    }

    var lastXPGain: XPToastData? {
        interactor.xpAppState.lastXPGain
    }

    var lastFireRoundActivation: Bool {
        interactor.xpAppState.pendingFireRoundActivation
    }

    var lastStreakTierUp: StreakTier? {
        interactor.xpAppState.pendingStreakTierUp
    }

    var lastChallengeCompletion: String? {
        interactor.xpAppState.pendingChallengeCompletion
    }

    var pendingTechniquePromotion: TechniquePromotionData? {
        interactor.pendingTechniquePromotion
    }

    // MARK: - Signal Handlers

    func onAchievementUnlocked(_ achievementId: AchievementId) {
        interactor.consumeUnlockedAchievement()
        unlockQueue.append(achievementId)
        guard !isCelebrationShowing else { return }
        showNextAchievement()
    }

    func onXPGained(_ data: XPToastData) {
        interactor.xpAppState.lastXPGain = nil
        xpQueue.append(data)
        drainQueue()
    }

    func onFireRoundActivated() {
        interactor.xpAppState.pendingFireRoundActivation = false
        guard !isCelebrationShowing else { return }
        showFireRound()
    }

    func onStreakTierUpDetected(_ tier: StreakTier) {
        interactor.xpAppState.pendingStreakTierUp = nil
        guard !isCelebrationShowing else { return }
        showStreakTierUp(tier)
    }

    func onChallengeCompletionReceived(_ title: String) {
        interactor.xpAppState.pendingChallengeCompletion = nil
        pendingChallengeToast = title
    }

    func onChallengeToastDismissed() {
        pendingChallengeToast = nil
    }

    // MARK: - Technique Promotion

    func onPendingTechniquePromotionReceived(_ data: TechniquePromotionData) {
        router.showTechniquePromotion(
            data: data,
            onPromote: { [weak self] in self?.onPromoteTechnique() },
            onSnooze: { [weak self] in self?.onSnoozeTechniquePromotion() },
            onDismissPressed: { [weak self] in self?.onTechniquePromotionDismissPressed() },
            onSheetDismissed: { [weak self] in self?.onTechniquePromotionSheetDismissed() }
        )
    }

    func onPromoteTechnique() {
        guard let data = interactor.pendingTechniquePromotion else { return }
        interactor.trackEvent(event: Event.techniquePromoted(techniqueId: data.techniqueId, toStage: data.suggestedStage))
        let stage = ProgressionStage(rawValue: data.suggestedStage.lowercased()) ?? .drilling
        try? interactor.setTechniqueStage(techniqueId: data.techniqueId, stage: stage)
        interactor.clearPendingTechniquePromotion()
        router.dismissScreen()
    }

    func onSnoozeTechniquePromotion() {
        interactor.trackEvent(event: Event.techniquePromotionSnoozed)
        interactor.clearPendingTechniquePromotion()
        router.dismissScreen()
    }

    func onTechniquePromotionDismissPressed() {
        interactor.trackEvent(event: Event.techniquePromotionDismissed)
        interactor.clearPendingTechniquePromotion()
        router.dismissScreen()
    }

    // Fires when the sheet is dismissed by swipe or backdrop. If the user didn't
    // already tap promote/snooze/dismiss, we still want to clear the signal so
    // the prompt doesn't re-appear next frame. Idempotent when state is already nil.
    func onTechniquePromotionSheetDismissed() {
        guard interactor.pendingTechniquePromotion != nil else { return }
        interactor.trackEvent(event: Event.techniquePromotionDismissed)
        interactor.clearPendingTechniquePromotion()
    }

    // MARK: - Gym Arrival

    func onGymArrival(gymId: String) {
        interactor.trackEvent(event: Event.gymArrivalDetected(gymId: gymId))
        guard !isShowingCheckIn else { return }
        guard let gym = interactor.gyms.first(where: { $0.gymId == gymId }) else { return }
        let schedule = interactor.closestSchedule(forGymId: gymId, at: Date())
        isShowingCheckIn = true
        router.showCheckInView(
            gym: gym,
            schedule: schedule,
            checkInMethod: .geofence,
            onDismiss: { [weak self] in
                self?.onCheckInDismissed()
            }
        )
    }

    private func onCheckInDismissed() {
        interactor.trackEvent(event: Event.checkInPromptDismissed)
        isShowingCheckIn = false
    }

    // MARK: - Toast

    func onXPToastDismissed() {
        pendingXPToast = nil
        scheduleNextDrain()
    }

    // MARK: - Private — Show Modals via Router

    private func showNextAchievement() {
        guard !unlockQueue.isEmpty else { return }
        let achievementId = unlockQueue.removeFirst()
        isCelebrationShowing = true
        interactor.trackEvent(event: Event.achievementDisplayed(id: achievementId.rawValue))
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            router.showAchievementModal(
                achievementId: achievementId,
                accentColor: .wazaAccent,
                onDismiss: { [weak self] in self?.onModalDismissed(.achievementDismissed) }
            )
            playCelebrationHaptic()
        }
    }

    private func showFireRound() {
        isCelebrationShowing = true
        router.showFireRoundModal(
            onDismiss: { [weak self] in self?.onModalDismissed(.fireRoundDismissed) }
        )
        playCelebrationHaptic()
    }

    private func showStreakTierUp(_ tier: StreakTier) {
        isCelebrationShowing = true
        router.showStreakTierUpModal(
            tier: tier,
            accentColor: .wazaAccent,
            onDismiss: { [weak self] in self?.onModalDismissed(.streakTierUpDismissed) }
        )
        playCelebrationHaptic()
    }

    private func showLevelUp(_ data: XPToastData) {
        guard let level = data.newLevel, let title = data.newTitle else { return }
        isCelebrationShowing = true
        router.showLevelUpModal(
            level: level,
            title: title,
            xpGained: data.totalPoints,
            accentColor: .wazaAccent,
            onDismiss: { [weak self] in self?.onModalDismissed(.levelUpDismissed) }
        )
        playCelebrationHaptic()
    }

    // MARK: - Private — Dismiss & Drain

    private func onModalDismissed(_ event: Event) {
        interactor.trackEvent(event: event)
        router.dismissCelebrationModal()
        isCelebrationShowing = false

        // Continue draining queues
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            if !unlockQueue.isEmpty {
                showNextAchievement()
            } else {
                drainQueue()
            }
        }
    }

    private func drainQueue() {
        guard !isCelebrationShowing, pendingXPToast == nil, !xpQueue.isEmpty else { return }

        let data = xpQueue.removeFirst()
        if data.leveledUp {
            showLevelUp(data)
        } else {
            pendingXPToast = data
        }
    }

    private func scheduleNextDrain() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            drainQueue()
        }
    }

    // MARK: - Shared Haptics

    private func playCelebrationHaptic() {
        Task { @MainActor in
            interactor.playHaptic(option: .heavy)
            try? await Task.sleep(nanoseconds: 150_000_000)
            interactor.playHaptic(option: .heavy)
            try? await Task.sleep(nanoseconds: 250_000_000)
            interactor.playHaptic(option: .success)
        }
    }
}

extension TabBarPresenter {
    enum Event: LoggableEvent {
        case achievementDisplayed(id: String)
        case achievementDismissed
        case gymArrivalDetected(gymId: String)
        case checkInPromptDismissed
        case levelUpDismissed
        case fireRoundDismissed
        case streakTierUpDismissed
        case techniquePromoted(techniqueId: String, toStage: String)
        case techniquePromotionSnoozed
        case techniquePromotionDismissed

        var eventName: String {
            switch self {
            case .achievementDisplayed:       return "TabBar_Achievement_Displayed"
            case .achievementDismissed:       return "TabBar_Achievement_Dismissed"
            case .gymArrivalDetected:         return "TabBar_GymArrival_Detected"
            case .checkInPromptDismissed:     return "TabBar_CheckIn_Dismissed"
            case .levelUpDismissed:           return "TabBar_LevelUp_Dismissed"
            case .fireRoundDismissed:         return "TabBar_FireRound_Dismissed"
            case .streakTierUpDismissed:      return "TabBar_StreakTierUp_Dismissed"
            case .techniquePromoted:          return "TabBar_Technique_Promoted"
            case .techniquePromotionSnoozed:  return "TabBar_Technique_PromotionSnoozed"
            case .techniquePromotionDismissed: return "TabBar_Technique_PromotionDismissed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .achievementDisplayed(id: let id):
                return ["achievement_id": id]
            case .gymArrivalDetected(gymId: let gymId):
                return ["gym_id": gymId]
            case .techniquePromoted(techniqueId: let id, toStage: let stage):
                return ["technique_id": id, "to_stage": stage]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
