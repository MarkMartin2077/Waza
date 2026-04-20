import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    private let interactor: DashboardInteractor
    private let router: DashboardRouter
    let delegate: DashboardDelegate

    private(set) var sessions: [BJJSessionModel] = []
    private(set) var sessionStats: SessionStats = .empty
    private(set) var streakCount: Int = 0
    private(set) var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)?
    private(set) var xpLevelInfo: XPLevelInfo = XPLevelSystem.levelInfo(forXP: 0)
    private(set) var streakTier: StreakTier = .none
    private(set) var fireRoundExpiresAt: Date?
    private(set) var isStreakAtRisk: Bool = false
    private(set) var freezesAvailable: Int = 0
    private(set) var challenges: [WeeklyChallengeModel] = []
    private(set) var completedChallengeCount: Int = 0
    private(set) var techniqueCount: Int = 0
    private(set) var perfectWeekActive: Bool = false
    var showChallengesTip: Bool = false
    var showMonthlyReportBanner: Bool = false

    init(interactor: DashboardInteractor, router: DashboardRouter, delegate: DashboardDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
    }

    func loadData() {
        sessions = interactor.recentSessions
        sessionStats = interactor.sessionStats
        streakCount = interactor.currentStreakData.currentStreak ?? 0
        nextUpcomingClass = interactor.nextUpcomingClass
        let totalXP = interactor.currentExperiencePointsData.pointsAllTime ?? 0
        xpLevelInfo = XPLevelSystem.levelInfo(forXP: totalXP)
        streakTier = StreakTier.tier(forDays: streakCount)
        fireRoundExpiresAt = XPMultiplierCalculator.fireRoundExpiresAt()

        let streakData = interactor.currentStreakData
        isStreakAtRisk = streakData.isStreakAtRisk
        freezesAvailable = streakData.freezesAvailableCount ?? 0

        // Schedule/cancel streak risk notification
        if streakCount >= 2 {
            StreakRiskNotificationScheduler.scheduleIfNeeded(
                currentStreak: streakCount,
                isAtRisk: isStreakAtRisk
            )
        }

        interactor.generateChallengesIfNeeded()
        challenges = interactor.currentChallenges
        completedChallengeCount = interactor.completedChallengeCount
        techniqueCount = interactor.allTechniques.count
        perfectWeekActive = sessionStats.thisWeekSessions >= XPMultiplierCalculator.perfectWeekTarget

        // Onboarding tips
        showChallengesTip = !challenges.isEmpty && !OnboardingFlags.hasSeenChallengesTip
        showMonthlyReportBanner = sessionStats.totalSessions > 0
            && OnboardingFlags.shouldShowMonthlyReportBanner()

        interactor.updateWidgetData(WazaWidgetData(
            streakCount: streakCount,
            accentColorHex: Color.wazaAccentHex,
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

    var isGymSet: Bool {
        !interactor.gyms.isEmpty
    }

    var sessionsThisWeek: Int {
        sessionStats.thisWeekSessions
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

    var greetingText: String {
        let name = userFirstName
        if name == "Athlete" || name.isEmpty {
            return greeting
        }
        return "\(greeting), \(name)"
    }

    var hoursThisWeekFormatted: String {
        let range = DateRange.thisCalendarWeek
        let weekSessions = sessions.filter { $0.date >= range.start && $0.date <= range.end }
        let totalSeconds = Int(weekSessions.reduce(0) { $0 + $1.duration })
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours == 0 { return "\(minutes)m" }
        if minutes == 0 { return "\(hours)h" }
        return "\(hours)h \(minutes)m"
    }

    /// Weekly practice grid data — one entry per day (Mon–Sun) with the session if trained.
    /// Always Mon–Sun regardless of locale's firstWeekday setting.
    var weeklyPracticeGrid: [WeekDay] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Force Monday start
        let now = Date()

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return []
        }
        let mondayStart = weekInterval.start

        let weekSessions = sessions.filter {
            $0.date >= mondayStart && $0.date < calendar.date(byAdding: .day, value: 7, to: mondayStart)!
        }

        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        return (0..<7).map { dayIndex in
            let dayDate = calendar.date(byAdding: .day, value: dayIndex, to: mondayStart)!
            let daySessions = weekSessions.filter { calendar.isDate($0.date, inSameDayAs: dayDate) }
            let isToday = calendar.isDateInToday(dayDate)
            return WeekDay(
                label: dayLabels[dayIndex],
                sessions: daySessions,
                isToday: isToday
            )
        }
    }

    struct WeekDay {
        let label: String
        let sessions: [BJJSessionModel]
        let isToday: Bool
        var isTrained: Bool { !sessions.isEmpty }
        /// Most recent session for display (kanji, type label).
        var latestSession: BJJSessionModel? { sessions.last }
    }

    // MARK: - User actions

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logSessionTapped)
        router.showSessionEntryView(onDismiss: { [weak self] in
            guard let self else { return }
            let interactor = self.interactor
            Task { @MainActor in
                await interactor.endTrainingLiveActivity()
            }
            self.loadData()
        })
    }

    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        router.showSessionDetailView(session: session)
    }

    func onCheckInTapped(gym: GymLocationModel, schedule: ClassScheduleModel?) {
        interactor.trackEvent(event: Event.checkInTapped)
        router.showCheckInView(gym: gym, schedule: schedule, checkInMethod: .manual, onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    func onUseStreakFreezePressed() {
        interactor.trackEvent(event: Event.streakFreezeUsed)
        Task {
            do {
                try await interactor.useStreakFreezes()
                loadData()
            } catch {
                router.showAlert(error: error)
            }
        }
    }

    func onDevSettingsTapped() {
        interactor.trackEvent(event: Event.devSettingsTapped)
        router.showDevSettingsView()
    }

    // MARK: - Discovery / Tips

    func onDismissChallengesTip() {
        interactor.trackEvent(event: Event.challengesTipDismissed)
        OnboardingFlags.hasSeenChallengesTip = true
        showChallengesTip = false
    }

    func onTechniqueJournalCardTapped() {
        interactor.trackEvent(event: Event.techniqueJournalCardTapped)
        router.showTechniqueJournalView()
    }

    func onMonthlyReportBannerTapped() {
        interactor.trackEvent(event: Event.monthlyReportBannerTapped)
        OnboardingFlags.dismissMonthlyReportBanner()
        showMonthlyReportBanner = false
        router.showMonthlyReportView()
    }

    func onDismissMonthlyReportBanner() {
        interactor.trackEvent(event: Event.monthlyReportBannerDismissed)
        OnboardingFlags.dismissMonthlyReportBanner()
        showMonthlyReportBanner = false
    }
}

// MARK: - Events

extension DashboardPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case logSessionTapped
        case sessionTapped
        case checkInTapped
        case devSettingsTapped
        case streakFreezeUsed
        case challengesTipDismissed
        case techniqueJournalCardTapped
        case monthlyReportBannerTapped
        case monthlyReportBannerDismissed

        var eventName: String {
            switch self {
            case .onAppear:                      return "DashboardView_Appear"
            case .logSessionTapped:              return "DashboardView_LogSession_Tap"
            case .sessionTapped:                 return "DashboardView_Session_Tap"
            case .checkInTapped:                 return "DashboardView_CheckIn_Tap"
            case .devSettingsTapped:             return "DashboardView_DevSettings_Tap"
            case .streakFreezeUsed:              return "DashboardView_StreakFreeze_Used"
            case .challengesTipDismissed:        return "DashboardView_ChallengesTip_Dismissed"
            case .techniqueJournalCardTapped:    return "DashboardView_TechniqueJournalCard_Tap"
            case .monthlyReportBannerTapped:     return "DashboardView_MonthlyReportBanner_Tap"
            case .monthlyReportBannerDismissed:  return "DashboardView_MonthlyReportBanner_Dismissed"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}

struct DashboardDelegate {
    var eventParameters: [String: Any]? { nil }
}
