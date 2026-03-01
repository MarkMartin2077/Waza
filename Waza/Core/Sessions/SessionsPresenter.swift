import SwiftUI

@Observable
@MainActor
class SessionsPresenter {
    let router: any SessionsRouter
    let interactor: any SessionsInteractor

    private(set) var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)?
    private var gymArrivalObserver: NSObjectProtocol?

    init(router: any SessionsRouter, interactor: any SessionsInteractor) {
        self.router = router
        self.interactor = interactor
    }

    var sessions: [BJJSessionModel] {
        interactor.allSessions
    }

    var beltAccentColor: Color {
        interactor.currentBeltEnum.accentColor
    }

    var sessionCount: Int { sessions.count }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
        observeGymArrival()
    }

    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        router.showSessionDetailView(session: session)
    }

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logTapped)
        router.showSessionEntryView(onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    func onDeleteConfirmed(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.deleteConfirmed)
        do {
            try interactor.deleteSession(session)
        } catch {
            interactor.trackEvent(event: Event.deleteFailed(error: error))
        }
    }

    func onCheckInTapped(gym: GymLocationModel, schedule: ClassScheduleModel?) {
        interactor.trackEvent(event: Event.checkInTapped)
        router.showCheckInView(gym: gym, schedule: schedule, onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    // MARK: - Private

    private func loadData() {
        nextUpcomingClass = interactor.nextUpcomingClass
        updateWidgets()
    }

    private func updateWidgets() {
        let streak = interactor.currentStreakData.currentStreak ?? 0
        let stats = interactor.sessionStats
        WidgetDataStore.shared.update(WazaWidgetData(
            streakCount: streak,
            accentColorHex: interactor.currentBeltEnum.accentColorHex,
            beltDisplayName: interactor.currentBeltEnum.displayName,
            sessionsThisWeek: stats.thisWeekSessions,
            nextClassTypeDisplayName: nextUpcomingClass?.0.sessionType.displayName,
            nextClassGymName: nextUpcomingClass?.1.name,
            nextClassDayOfWeek: nextUpcomingClass?.0.dayOfWeek,
            nextClassStartHour: nextUpcomingClass?.0.startHour,
            nextClassStartMinute: nextUpcomingClass?.0.startMinute
        ))
    }

    private func observeGymArrival() {
        guard gymArrivalObserver == nil else { return }
        gymArrivalObserver = NotificationCenter.default.addObserver(
            forName: .gymArrival,
            object: nil,
            queue: nil
        ) { [weak self] notification in
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

extension SessionsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case sessionTapped
        case logTapped
        case checkInTapped
        case deleteConfirmed
        case deleteFailed(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:        return "SessionsView_Appear"
            case .sessionTapped:   return "SessionsView_SessionTap"
            case .logTapped:       return "SessionsView_LogTap"
            case .checkInTapped:   return "SessionsView_CheckIn_Tap"
            case .deleteConfirmed: return "SessionsView_Delete_Confirm"
            case .deleteFailed:    return "SessionsView_Delete_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .deleteFailed(error: let error): return error.eventParameters
            default: return nil
            }
        }

        var type: LogType {
            switch self {
            case .deleteFailed: return .severe
            default: return .analytic
            }
        }
    }
}
