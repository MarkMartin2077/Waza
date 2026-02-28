import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    private let interactor: DashboardInteractor
    private let router: DashboardRouter
    let delegate: DashboardDelegate

    private(set) var sessions: [BJJSessionModel] = []
    private(set) var sessionStats: SessionStats = .empty
    private(set) var currentBelt: BeltRecordModel?
    private(set) var streakCount: Int = 0
    private(set) var totalXP: Int = 0
    private(set) var isPremium: Bool = false
    private(set) var isAIAvailable: Bool = false
    private(set) var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)?
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
        sessions = interactor.recentSessions
        sessionStats = interactor.sessionStats
        currentBelt = interactor.currentBelt
        streakCount = interactor.currentStreakData.currentStreak ?? 0
        totalXP = interactor.currentExperiencePointsData.pointsAllTime ?? 0
        isPremium = interactor.isPremium
        isAIAvailable = interactor.isAIAvailable
        nextUpcomingClass = interactor.nextUpcomingClass
    }

    // MARK: - Computed display values

    var sessionsThisWeek: Int {
        sessionStats.thisWeekSessions
    }

    var beltDisplayName: String {
        currentBelt?.displayTitle ?? interactor.currentBeltEnum.displayName
    }

    // MARK: - User actions

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

    func onCheckInTapped(gym: GymLocationModel, schedule: ClassScheduleModel?) {
        interactor.trackEvent(event: Event.checkInTapped)
        router.showCheckInView(gym: gym, schedule: schedule, onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    func onAIInsightsTapped() {
        interactor.trackEvent(event: Event.aiInsightsTapped)
        router.showAIInsightsView()
    }

    func onUpgradeTapped() {
        interactor.trackEvent(event: Event.upgradeTapped)
        router.showPaywallView()
    }

    func onDevSettingsTapped() {
        interactor.trackEvent(event: Event.devSettingsTapped)
        router.showDevSettingsView()
    }

    // MARK: - Private

    private func observeGymArrival() {
        guard gymArrivalObserver == nil else { return }
        gymArrivalObserver = NotificationCenter.default.addObserver(
            forName: .gymArrival,
            object: nil,
            queue: nil
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
}

// MARK: - Events

extension DashboardPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case logSessionTapped
        case sessionTapped
        case checkInTapped
        case aiInsightsTapped
        case upgradeTapped
        case devSettingsTapped

        var eventName: String {
            switch self {
            case .onAppear:          return "DashboardView_Appear"
            case .logSessionTapped:  return "DashboardView_LogSession_Tap"
            case .sessionTapped:     return "DashboardView_Session_Tap"
            case .checkInTapped:     return "DashboardView_CheckIn_Tap"
            case .aiInsightsTapped:  return "DashboardView_AIInsights_Tap"
            case .upgradeTapped:     return "DashboardView_Upgrade_Tap"
            case .devSettingsTapped: return "DashboardView_DevSettings_Tap"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}

struct DashboardDelegate {
    var eventParameters: [String: Any]? { nil }
}
