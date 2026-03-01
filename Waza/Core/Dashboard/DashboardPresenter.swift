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

        WidgetDataStore.shared.update(WazaWidgetData(
            streakCount: streakCount,
            accentColorHex: interactor.currentBeltEnum.accentColorHex,
            beltDisplayName: interactor.currentBeltEnum.displayName,
            sessionsThisWeek: sessionStats.thisWeekSessions,
            nextClassTypeDisplayName: nextUpcomingClass?.0.sessionType.displayName,
            nextClassGymName: nextUpcomingClass?.1.name,
            nextClassDayOfWeek: nextUpcomingClass?.0.dayOfWeek,
            nextClassStartHour: nextUpcomingClass?.0.startHour,
            nextClassStartMinute: nextUpcomingClass?.0.startMinute
        ))
    }

    // MARK: - Computed display values

    var isNewUser: Bool {
        sessionStats.totalSessions == 0
    }

    var isBeltSet: Bool {
        currentBelt != nil
    }

    var isGymSet: Bool {
        !interactor.gyms.isEmpty
    }

    var weeklyGoalText: String {
        let count = sessionStats.thisWeekSessions
        if let goal = interactor.trainingGoalPerWeek {
            return "\(count) / \(goal) this week"
        }
        return "\(count) this week"
    }

    var sessionsThisWeek: Int {
        sessionStats.thisWeekSessions
    }

    var beltDisplayName: String {
        currentBelt?.displayTitle ?? interactor.currentBeltEnum.displayName
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Ready to train?"
        }
    }

    var userFirstName: String {
        interactor.currentUserName.components(separatedBy: " ").first ?? "Athlete"
    }

    var beltAccentColor: Color {
        interactor.currentBeltEnum.accentColor
    }

    var totalTrainingTimeFormatted: String {
        let totalSeconds = Int(sessionStats.totalTrainingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours == 0 { return "\(minutes)m" }
        if minutes == 0 { return "\(hours)h" }
        return "\(hours)h \(minutes)m"
    }

    // MARK: - User actions

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logSessionTapped)
        router.showSessionEntryView(onDismiss: { [weak self] in
            Task { @MainActor [weak self] in
                await self?.interactor.endTrainingLiveActivity()
            }
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

    func onSetBeltTapped() {
        interactor.trackEvent(event: Event.setBeltTapped)
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
        case setBeltTapped

        var eventName: String {
            switch self {
            case .onAppear:          return "DashboardView_Appear"
            case .logSessionTapped:  return "DashboardView_LogSession_Tap"
            case .sessionTapped:     return "DashboardView_Session_Tap"
            case .checkInTapped:     return "DashboardView_CheckIn_Tap"
            case .aiInsightsTapped:  return "DashboardView_AIInsights_Tap"
            case .upgradeTapped:     return "DashboardView_Upgrade_Tap"
            case .devSettingsTapped: return "DashboardView_DevSettings_Tap"
            case .setBeltTapped:     return "DashboardView_SetBelt_Tap"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}

struct DashboardDelegate {
    var eventParameters: [String: Any]? { nil }
}
