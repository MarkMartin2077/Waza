import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    private let interactor: DashboardInteractor
    private let router: DashboardRouter
    let delegate: DashboardDelegate

    private(set) var recentSessions: [BJJSessionModel] = []
    private(set) var sessionStats: SessionStats = .empty
    private(set) var currentBelt: BeltRecordModel?
    private(set) var activeGoals: [TrainingGoalModel] = []
    private(set) var streakCount: Int = 0
    private(set) var totalXP: Int = 0
    private(set) var isPremium: Bool = false
    private(set) var isAIAvailable: Bool = false
    private(set) var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)?
    let weeklyAttendanceTarget: Int = 3
    private var gymArrivalObserver: NSObjectProtocol?

    init(interactor: DashboardInteractor, router: DashboardRouter, delegate: DashboardDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
        observeGymArrival()
    }

    func loadData() {
        recentSessions = interactor.recentSessions
        sessionStats = interactor.sessionStats
        currentBelt = interactor.currentBelt
        activeGoals = Array(interactor.activeGoals.prefix(3))
        streakCount = interactor.currentStreakData.currentStreak ?? 0
        totalXP = interactor.currentExperiencePointsData.pointsAllTime ?? 0
        isPremium = interactor.isPremium
        isAIAvailable = interactor.isAIAvailable
        nextUpcomingClass = interactor.nextUpcomingClass
    }

    var weeklyAttendanceCount: Int {
        interactor.weeklyAttendanceCount(weekOf: Date())
    }

    func onScheduleTapped() {
        interactor.trackEvent(event: Event.scheduleTapped)
        router.showClassScheduleView()
    }

    func onCheckInTapped(gym: GymLocationModel, schedule: ClassScheduleModel?) {
        interactor.trackEvent(event: Event.checkInTapped)
        router.showCheckInView(gym: gym, schedule: schedule, onDismiss: nil)
    }

    private func observeGymArrival() {
        guard gymArrivalObserver == nil else { return }
        gymArrivalObserver = NotificationCenter.default.addObserver(
            forName: .gymArrival,
            object: nil,
            queue: nil  // deliver on poster's thread; hop to MainActor explicitly below
        ) { [weak self] notification in
            // Extract String (Sendable) before hopping actors — Notification is not Sendable
            let gymId = notification.userInfo?["gymId"] as? String
            Task { @MainActor [weak self] in
                guard let self, let gymId else { return }
                if let gym = self.interactor.gyms.first(where: { $0.gymId == gymId }) {
                    let schedule = self.interactor.schedules.first(where: {
                        $0.gymId == gymId && $0.isActive
                    })
                    self.router.showCheckInView(gym: gym, schedule: schedule, onDismiss: nil)
                }
            }
        }
    }

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logSessionTapped)
        router.showSessionEntryView(onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        router.showSessionDetailView(session: session)
    }

    func onGoalsTapped() {
        interactor.trackEvent(event: Event.goalsTapped)
        router.showGoalsPlanningView()
    }

    func onDevSettingsTapped() {
        router.showDevSettingsView()
    }

    func onUpgradeTapped() {
        interactor.trackEvent(event: Event.upgradeTapped)
        router.showPaywallView()
    }

    func onAIInsightsTapped() {
        interactor.trackEvent(event: Event.aiInsightsTapped)
        router.showAIInsightsView()
    }

    var beltDisplayName: String {
        guard let belt = currentBelt else {
            return interactor.currentBeltEnum.displayName
        }
        return belt.displayTitle
    }
}

extension DashboardPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case logSessionTapped
        case sessionTapped
        case goalsTapped
        case upgradeTapped
        case aiInsightsTapped
        case scheduleTapped
        case checkInTapped

        var eventName: String {
            switch self {
            case .onAppear:         return "DashboardView_Appear"
            case .logSessionTapped: return "DashboardView_LogSession_Tap"
            case .sessionTapped:    return "DashboardView_Session_Tap"
            case .goalsTapped:      return "DashboardView_Goals_Tap"
            case .upgradeTapped:    return "DashboardView_Upgrade_Tap"
            case .aiInsightsTapped: return "DashboardView_AIInsights_Tap"
            case .scheduleTapped:   return "DashboardView_Schedule_Tap"
            case .checkInTapped:    return "DashboardView_CheckIn_Tap"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}

struct DashboardDelegate {
    var eventParameters: [String: Any]? { nil }
}
