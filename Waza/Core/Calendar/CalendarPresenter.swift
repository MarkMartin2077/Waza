import SwiftUI

@Observable
@MainActor
class CalendarPresenter {
    private let interactor: any CalendarInteractor
    private let router: any CalendarRouter
    let delegate: CalendarDelegate

    private(set) var days: [CalendarDayModel] = []
    private(set) var monthTitle: String = ""
    var displayedMonthAnchor: Date
    var selectedDay: CalendarDayModel?

    var isOnCurrentMonth: Bool {
        let current = Calendar.current.dateComponents([.year, .month], from: Date())
        let displayed = Calendar.current.dateComponents([.year, .month], from: displayedMonthAnchor)
        return current.year == displayed.year && current.month == displayed.month
    }

    var isFirstRunEmpty: Bool {
        interactor.allSessions.isEmpty && interactor.schedules.isEmpty && isOnCurrentMonth
    }

    // Cache: "yyyy-MM" → [CalendarDayModel] for the last 3 months navigated.
    private var monthCache: [String: [CalendarDayModel]] = [:]
    private static let cacheCap = 3

    // Deferred routing: set when the user taps a CTA in the day-detail sheet.
    // Runs in onDismissDayDetail so the next screen only presents after the sheet
    // finishes dismissing — avoids stacked sheets.
    private enum PendingAction {
        case logSession(initialDate: Date?)
        case addSchedule
        case openSession(BJJSessionModel)
        case openCheckIn(ScheduledClassOccurrence)
        case setupGym
        case viewAllSessions
    }
    private var pendingAction: PendingAction?

    init(
        interactor: any CalendarInteractor,
        router: any CalendarRouter,
        delegate: CalendarDelegate = CalendarDelegate()
    ) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
        let firstOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: Date())
        ) ?? Date()
        self.displayedMonthAnchor = firstOfMonth
    }

    // MARK: - Lifecycle

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        // Clear cache so sessions logged elsewhere (Dashboard, deep links) show on return.
        monthCache.removeAll()
        loadMonth()
    }

    // MARK: - Navigation

    func onPrevMonth() {
        interactor.trackEvent(event: Event.monthChanged(direction: "prev"))
        guard let prev = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonthAnchor) else { return }
        displayedMonthAnchor = prev
        loadMonth()
    }

    func onNextMonth() {
        interactor.trackEvent(event: Event.monthChanged(direction: "next"))
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonthAnchor) else { return }
        displayedMonthAnchor = next
        loadMonth()
    }

    func onJumpToToday() {
        interactor.trackEvent(event: Event.jumpToTodayTapped)
        let firstOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: Date())
        ) ?? Date()
        guard firstOfMonth != displayedMonthAnchor else { return }
        displayedMonthAnchor = firstOfMonth
        loadMonth()
    }

    // MARK: - Day Interaction

    func onDayTapped(_ day: CalendarDayModel) {
        interactor.trackEvent(event: Event.dayTapped(
            hasSessions: day.hasSessions,
            hasScheduled: day.hasScheduled,
            isFuture: day.isFuture
        ))

        let isOldPastDay = !day.isFuture && !day.isToday && !day.hasSessions
            && day.date < Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()

        if isOldPastDay {
            // Give tactile + visual feedback so the tap doesn't read as broken.
            interactor.playHaptic(option: .warning)
            router.showSimpleAlert(title: "Too far back", subtitle: "Sessions older than 14 days can't be logged retroactively.")
            return
        }

        if day.sessions.count == 1 && day.scheduledOccurrences.isEmpty {
            router.showSessionDetailView(session: day.sessions[0])
            return
        }

        if day.sessions.isEmpty && day.scheduledOccurrences.count == 1 && day.isFuture {
            let occurrence = day.scheduledOccurrences[0]
            let windowStart = occurrence.occursAt.addingTimeInterval(-30 * 60)
            let windowEnd = occurrence.occursAt.addingTimeInterval(30 * 60)
            let now = Date()
            if now >= windowStart && now <= windowEnd {
                router.showCheckInView(
                    gym: occurrence.gym,
                    schedule: occurrence.schedule,
                    checkInMethod: .manual,
                    onDismiss: { [weak self] in self?.loadMonth() }
                )
                return
            }
        }

        let tappedDate = day.date
        router.showCalendarDayDetailSheet(
            day: day,
            callbacks: CalendarDayDetailCallbacks(
                onSessionTap: { [weak self] session in self?.onSessionTapped(session) },
                onOccurrenceTap: { [weak self] occurrence in self?.onOccurrenceTapped(occurrence) },
                onAddSchedule: { [weak self] in self?.onAddScheduleTapped() },
                onLogSession: { [weak self] in self?.onLogSessionTapped(initialDate: tappedDate) },
                onViewAllSessions: { [weak self] in self?.onViewAllSessionsTapped() },
                onDismiss: { [weak self] in self?.onDismissDayDetail() }
            )
        )
    }

    // Sheet CTAs only set pendingAction — the sheet itself dismisses via
    // @Environment(\.dismiss). onDismissDayDetail then runs the queued action.
    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        pendingAction = .openSession(session)
    }

    func onOccurrenceTapped(_ occurrence: ScheduledClassOccurrence) {
        interactor.trackEvent(event: Event.occurrenceTapped)
        let now = Date()
        let windowStart = occurrence.occursAt.addingTimeInterval(-30 * 60)
        let windowEnd = occurrence.occursAt.addingTimeInterval(30 * 60)
        if now >= windowStart && now <= windowEnd {
            interactor.trackEvent(event: Event.checkInTapped)
            pendingAction = .openCheckIn(occurrence)
        }
    }

    func onLogSessionTapped(initialDate: Date? = nil) {
        interactor.trackEvent(event: Event.logSessionTapped)
        // Past days (backdated logging) pre-fill the date picker; today/future fall back to Date().
        let targetDate: Date?
        if let initialDate, Calendar.current.compare(initialDate, to: Date(), toGranularity: .day) == .orderedAscending {
            targetDate = initialDate
        } else {
            targetDate = nil
        }
        pendingAction = .logSession(initialDate: targetDate)
    }

    func onAddScheduleTapped() {
        interactor.trackEvent(event: Event.addScheduleTapped)
        // If the user has no gyms yet, take them into gym setup first so "Add to
        // schedule" always leads somewhere visible instead of silently failing.
        pendingAction = interactor.gymsById.isEmpty ? .setupGym : .addSchedule
    }

    func onViewAllSessionsTapped() {
        interactor.trackEvent(event: Event.viewAllSessionsTapped)
        pendingAction = .viewAllSessions
    }

    func onDismissDayDetail() {
        let action = pendingAction
        pendingAction = nil
        runPendingAction(action)
        loadMonth()
    }

    private func runPendingAction(_ action: PendingAction?) {
        guard let action else { return }
        switch action {
        case .logSession(let initialDate):
            router.showSessionEntryView(initialDate: initialDate, onDismiss: { [weak self] in self?.reload() })
        case .addSchedule:
            let gyms = Array(interactor.gymsById.values).sorted { $0.name < $1.name }
            guard let firstGym = gyms.first else { return }
            if gyms.count == 1 {
                router.showAddScheduleSheet(
                    gymId: firstGym.gymId,
                    existingSchedule: nil,
                    onDismiss: { [weak self] in self?.reload() }
                )
            } else {
                router.showGymPickerForAddSchedule(gyms: gyms) { [weak self] gymId in
                    self?.router.showAddScheduleSheet(
                        gymId: gymId,
                        existingSchedule: nil,
                        onDismiss: { [weak self] in self?.reload() }
                    )
                }
            }
        case .openSession(let session):
            router.showSessionDetailView(session: session)
        case .openCheckIn(let occurrence):
            router.showCheckInView(
                gym: occurrence.gym,
                schedule: occurrence.schedule,
                checkInMethod: .manual,
                onDismiss: { [weak self] in self?.reload() }
            )
        case .setupGym:
            router.showGymSetupView(existingGym: nil, onDismiss: { [weak self] in self?.reload() })
        case .viewAllSessions:
            router.showSessionsView()
        }
    }

    /// Drops the current month's cache entry and rebuilds. Use after any write
    /// (session save, check-in, schedule add, gym setup) so the grid reflects changes.
    private func reload() {
        monthCache.removeValue(forKey: monthCacheKey(for: displayedMonthAnchor))
        loadMonth()
    }

    // MARK: - Private

    private func loadMonth() {
        let key = monthCacheKey(for: displayedMonthAnchor)
        if let cached = monthCache[key] {
            days = cached
        } else {
            let built = interactor.buildCalendarMonth(anchor: displayedMonthAnchor)
            evictCacheIfNeeded()
            monthCache[key] = built
            days = built
        }
        monthTitle = formatMonthTitle(displayedMonthAnchor)
    }

    private func evictCacheIfNeeded() {
        if monthCache.count >= Self.cacheCap {
            if let oldest = monthCache.keys.sorted().first {
                monthCache.removeValue(forKey: oldest)
            }
        }
    }

    private func monthCacheKey(for date: Date) -> String {
        Self.cacheKeyFormatter.string(from: date)
    }

    private func formatMonthTitle(_ date: Date) -> String {
        Self.monthTitleFormatter.string(from: date).lowercased()
    }

    private static let cacheKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - Events

extension CalendarPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case monthChanged(direction: String)
        case dayTapped(hasSessions: Bool, hasScheduled: Bool, isFuture: Bool)
        case logSessionTapped
        case addScheduleTapped
        case sessionTapped
        case occurrenceTapped
        case checkInTapped
        case viewAllSessionsTapped
        case jumpToTodayTapped

        var eventName: String {
            switch self {
            case .onAppear:        return "Calendar_Appear"
            case .monthChanged:    return "Calendar_MonthChange"
            case .dayTapped:       return "Calendar_DayTap"
            case .logSessionTapped: return "Calendar_LogSession_Tap"
            case .addScheduleTapped: return "Calendar_AddSchedule_Tap"
            case .sessionTapped:   return "Calendar_Session_Tap"
            case .occurrenceTapped: return "Calendar_Occurrence_Tap"
            case .checkInTapped:   return "Calendar_CheckIn_Tap"
            case .viewAllSessionsTapped: return "Calendar_ViewAllSessions_Tap"
            case .jumpToTodayTapped: return "Calendar_JumpToToday_Tap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .monthChanged(direction: let dir):
                return ["direction": dir]
            case .dayTapped(hasSessions: let hasSessions, hasScheduled: let hasScheduled, isFuture: let isFuture):
                return ["has_sessions": hasSessions, "has_scheduled": hasScheduled, "is_future": isFuture]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
