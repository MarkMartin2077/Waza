import SwiftUI

@Observable
@MainActor
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter

    private(set) var sessionStats: SessionStats = .empty
    private(set) var earnedAchievements: [AchievementEarnedModel] = []
    private(set) var isPremium: Bool = false
    private(set) var userName: String = ""
    private(set) var gyms: [GymLocationModel] = []
    private(set) var scheduleCount: Int = 0
    private(set) var streakCount: Int = 0

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
        sessionStats = interactor.sessionStats
        earnedAchievements = interactor.earnedAchievements
        isPremium = interactor.isPremium
        userName = interactor.currentUser?.commonNameCalculated ?? interactor.currentUser?.displayName ?? "Grappler"
        gyms = interactor.gyms
        scheduleCount = interactor.schedules.count
        streakCount = interactor.currentStreakData.currentStreak ?? 0
    }

    // MARK: - Achievement actions

    func onAchievementsTapped() {
        interactor.trackEvent(event: Event.achievementsTapped)
        router.showAchievementsView()
    }

    // MARK: - Computed display values

    var beltAccentColor: Color {
        .wazaAccent
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

    var totalTrainingHoursText: String {
        String(format: "%.0f", sessionStats.totalTrainingHours)
    }

}

extension ProfilePresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: ProfileDelegate)
        case onDisappear(delegate: ProfileDelegate)
        case settingsPressed
        case manageScheduleTapped
        case achievementsTapped

        var eventName: String {
            switch self {
            case .onAppear:             return "ProfileView_Appear"
            case .onDisappear:          return "ProfileView_Disappear"
            case .settingsPressed:      return "ProfileView_Settings_Pressed"
            case .manageScheduleTapped: return "ProfileView_ManageSchedule_Tap"
            case .achievementsTapped:   return "ProfileView_Achievements_Tap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }

}
