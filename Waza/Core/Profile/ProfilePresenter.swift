import SwiftUI

// Allow AchievementId to be used with .sheet(item:)
extension AchievementId: Identifiable {
    public var id: String { rawValue }
}

@Observable
@MainActor
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter

    private(set) var currentBelt: BeltRecordModel?
    private(set) var beltHistory: [BeltRecordModel] = []
    private(set) var sessionStats: SessionStats = .empty
    private(set) var earnedAchievements: [AchievementEarnedModel] = []
    private(set) var isPremium: Bool = false
    private(set) var userName: String = ""
    private(set) var gyms: [GymLocationModel] = []
    private(set) var scheduleCount: Int = 0
    private(set) var classAttendance: [ClassAttendanceModel] = []

    var showAddPromotionSheet: Bool = false
    var errorMessage: String?
    var pendingUnlockAchievement: AchievementId?
    var selectedAchievement: AchievementId?

    // Tracks whether the first load has happened to avoid false unlock triggers on appear
    private var hasLoadedInitially: Bool = false

    // Sheet mode — true = initial belt setup (no achievement), false = promotion (triggers achievement)
    private(set) var isInitialBeltSetup: Bool = false

    // Promotion / setup form
    var newBelt: BJJBelt = .white
    var newStripes: Int = 0
    var newPromotionDate: Date = Date()
    var newAcademy: String = ""
    var newPromotionNotes: String = ""

    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: ProfileDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        loadData()
    }

    func onViewDisappear(delegate: ProfileDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func loadData() {
        // Capture count before refresh to detect new awards
        let previousCount = hasLoadedInitially ? earnedAchievements.count : interactor.earnedAchievements.count
        hasLoadedInitially = true

        currentBelt = interactor.currentBelt
        beltHistory = interactor.beltHistory
        sessionStats = interactor.sessionStats
        earnedAchievements = interactor.earnedAchievements
        isPremium = interactor.isPremium
        userName = interactor.currentUser?.commonNameCalculated ?? interactor.currentUser?.displayName ?? "Grappler"
        gyms = interactor.gyms
        scheduleCount = interactor.schedules.count
        classAttendance = interactor.classAttendance

        // Detect newly unlocked achievements (sorted newest first)
        if earnedAchievements.count > previousCount, pendingUnlockAchievement == nil {
            let newOnes = Array(earnedAchievements.prefix(earnedAchievements.count - previousCount))
            if let first = newOnes.first, let achievementId = AchievementId(rawValue: first.achievementId) {
                pendingUnlockAchievement = achievementId
                Task {
                    interactor.playHaptic(option: .heavy)
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    interactor.playHaptic(option: .success)
                }
            }
        }
    }

    // MARK: - Achievement actions

    func isAchievementEarned(_ id: AchievementId) -> Bool {
        earnedAchievements.contains { $0.achievementId == id.rawValue }
    }

    func earnedDate(for id: AchievementId) -> Date? {
        earnedAchievements.first { $0.achievementId == id.rawValue }?.earnedDate
    }

    func onAchievementTapped(_ id: AchievementId) {
        interactor.trackEvent(event: Event.achievementTapped)
        selectedAchievement = id
    }

    func onAchievementUnlockDismissed() {
        interactor.trackEvent(event: Event.achievementUnlockDismissed)
        interactor.playHaptic(option: .selection)
        pendingUnlockAchievement = nil
    }

    // MARK: - Computed display values

    var beltAccentColor: Color {
        interactor.currentBeltEnum.accentColor
    }

    var achievementsProgress: String {
        "\(earnedAchievements.count)/\(AchievementId.allCases.count)"
    }

    func onManageScheduleTapped() {
        interactor.trackEvent(event: Event.manageScheduleTapped)
        router.showClassScheduleView()
    }

    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }

    /// Called when the user taps "+" in Belt History — records a real promotion and triggers the achievement.
    func onAddPromotionTapped() {
        interactor.trackEvent(event: Event.addPromotionTapped)
        isInitialBeltSetup = false
        resetFormForPromotion()
        showAddPromotionSheet = true
    }

    /// Called from the empty-state CTA — records the user's current belt without triggering an achievement.
    func onSetCurrentBeltTapped() {
        interactor.trackEvent(event: Event.setCurrentBeltTapped)
        isInitialBeltSetup = true
        resetFormForInitialSetup()
        showAddPromotionSheet = true
    }

    func onSavePromotion() {
        interactor.trackEvent(event: Event.savePromotionTapped)
        do {
            if isInitialBeltSetup {
                try interactor.setInitialBelt(
                    belt: newBelt,
                    stripes: newStripes,
                    date: newPromotionDate,
                    academy: newAcademy.isEmpty ? nil : newAcademy,
                    notes: newPromotionNotes.isEmpty ? nil : newPromotionNotes
                )
            } else {
                _ = try interactor.addBeltPromotion(
                    belt: newBelt,
                    stripes: newStripes,
                    date: newPromotionDate,
                    academy: newAcademy.isEmpty ? nil : newAcademy,
                    notes: newPromotionNotes.isEmpty ? nil : newPromotionNotes
                )
            }
            showAddPromotionSheet = false
            loadData()
            interactor.playHaptic(option: .success)
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    func onCancelPromotion() {
        interactor.trackEvent(event: Event.cancelPromotion)
        showAddPromotionSheet = false
    }

    var sheetTitle: String {
        isInitialBeltSetup ? "Your Current Belt" : "Record Promotion"
    }

    var beltDisplayName: String {
        currentBelt?.displayTitle ?? interactor.currentBeltEnum.displayName
    }

    var totalTrainingHoursText: String {
        String(format: "%.0f", sessionStats.totalTrainingHours)
    }

    // MARK: - Private

    private func resetFormForPromotion() {
        newBelt = interactor.currentBeltEnum.nextBelt ?? interactor.currentBeltEnum
        newStripes = 0
        newPromotionDate = Date()
        newAcademy = ""
        newPromotionNotes = ""
    }

    private func resetFormForInitialSetup() {
        newBelt = interactor.currentBeltEnum
        newStripes = 0
        newPromotionDate = Date()
        newAcademy = ""
        newPromotionNotes = ""
    }
}

extension ProfilePresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: ProfileDelegate)
        case onDisappear(delegate: ProfileDelegate)
        case settingsPressed
        case setCurrentBeltTapped
        case addPromotionTapped
        case cancelPromotion
        case savePromotionTapped
        case saveFail(error: Error)
        case manageScheduleTapped
        case achievementTapped
        case achievementUnlockDismissed

        var eventName: String {
            switch self {
            case .onAppear:                   return "ProfileView_Appear"
            case .onDisappear:                return "ProfileView_Disappear"
            case .settingsPressed:            return "ProfileView_Settings_Pressed"
            case .setCurrentBeltTapped:       return "ProfileView_SetCurrentBelt_Tap"
            case .addPromotionTapped:         return "ProfileView_AddPromotion_Tap"
            case .cancelPromotion:            return "ProfileView_CancelPromotion_Tap"
            case .savePromotionTapped:        return "ProfileView_SavePromotion_Tap"
            case .saveFail:                   return "ProfileView_Save_Fail"
            case .manageScheduleTapped:       return "ProfileView_ManageSchedule_Tap"
            case .achievementTapped:          return "ProfileView_Achievement_Tap"
            case .achievementUnlockDismissed: return "ProfileView_AchievementUnlock_Dismiss"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .saveFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .saveFail: return .severe
            default: return .analytic
            }
        }
    }

}
