import SwiftUI

@Observable
@MainActor
class SessionsPresenter {
    let router: any SessionsRouter
    let interactor: any SessionsInteractor

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
    }

    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        router.showSessionDetailView(session: session)
    }

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logTapped)
        router.showSessionEntryView(onDismiss: nil)
    }
}

extension SessionsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case sessionTapped
        case logTapped

        var eventName: String {
            switch self {
            case .onAppear:     return "SessionsView_Appear"
            case .sessionTapped: return "SessionsView_SessionTap"
            case .logTapped:    return "SessionsView_LogTap"
            }
        }

        var parameters: [String: Any]? { nil }
        var type: LogType { .analytic }
    }
}
