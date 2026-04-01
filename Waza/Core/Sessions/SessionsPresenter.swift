import SwiftUI

@Observable
@MainActor
class SessionsPresenter {
    private let router: any SessionsRouter
    private let interactor: any SessionsInteractor

    private(set) var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)?

    init(router: any SessionsRouter, interactor: any SessionsInteractor) {
        self.router = router
        self.interactor = interactor
    }

    var sessions: [BJJSessionModel] {
        interactor.allSessions
    }

    var beltAccentColor: Color {
        .wazaAccent
    }

    var sessionCount: Int { sessions.count }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
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

    func onDeleteSwipeTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.deleteSwipeTapped)
        router.showAlert(.alert, title: "Delete Session?", subtitle: "This action cannot be undone.") {
            AnyView(
                Group {
                    Button("Delete", role: .destructive) { [weak self] in
                        self?.onDeleteConfirmed(session)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
        }
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
        router.showCheckInView(gym: gym, schedule: schedule, checkInMethod: .manual, onDismiss: { [weak self] in
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
        interactor.updateWidgetData(WazaWidgetData(
            streakCount: streak,
            accentColorHex: Color.wazaAccentHex,
            beltDisplayName: interactor.currentBeltEnum.displayName,
            sessionsThisWeek: stats.thisWeekSessions,
            nextClassTypeDisplayName: nextUpcomingClass?.0.sessionType.displayName,
            nextClassGymName: nextUpcomingClass?.1.name,
            nextClassDayOfWeek: nextUpcomingClass?.0.dayOfWeek,
            nextClassStartHour: nextUpcomingClass?.0.startHour,
            nextClassStartMinute: nextUpcomingClass?.0.startMinute
        ))
    }

}

extension SessionsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case sessionTapped
        case logTapped
        case checkInTapped
        case deleteSwipeTapped
        case deleteConfirmed
        case deleteFailed(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:          return "SessionsView_Appear"
            case .sessionTapped:     return "SessionsView_SessionTap"
            case .logTapped:         return "SessionsView_LogTap"
            case .checkInTapped:     return "SessionsView_CheckIn_Tap"
            case .deleteSwipeTapped: return "SessionsView_Delete_Swipe_Tap"
            case .deleteConfirmed:   return "SessionsView_Delete_Confirm"
            case .deleteFailed:      return "SessionsView_Delete_Fail"
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
