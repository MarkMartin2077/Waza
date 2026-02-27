import SwiftUI

@Observable
@MainActor
class SessionEntryPresenter {
    private let interactor: SessionEntryInteractor
    private let router: SessionEntryRouter
    let delegate: SessionEntryDelegate

    // Form fields
    var date: Date = Date()
    var sessionType: SessionType = .gi
    var durationMinutes: Int = 90
    var academy: String = ""
    var instructor: String = ""
    var notes: String = ""
    var preSessionMood: Int = 3
    var postSessionMood: Int = 3
    var roundsCount: Int = 0
    var whatWorkedWell: String = ""
    var needsImprovement: String = ""
    var keyInsights: String = ""
    var selectedFocusAreas: [String] = []
    var showMoodSection: Bool = false

    var isLoading: Bool = false
    var errorMessage: String?

    let availableFocusAreas = [
        "Guard Passing", "Guard Retention", "Back Takes", "Back Defense",
        "Side Control", "Mount", "Escapes", "Takedowns", "Wrestling",
        "Leg Locks", "Triangle", "Armbar", "Rear Naked Choke", "D'Arce",
        "Butterfly Guard", "De La Riva", "Half Guard", "Closed Guard",
        "Deep Half", "Spider Guard", "X-Guard", "Drilling", "Free Rolling"
    ]

    init(interactor: SessionEntryInteractor, router: SessionEntryRouter, delegate: SessionEntryDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func toggleFocusArea(_ area: String) {
        if selectedFocusAreas.contains(area) {
            selectedFocusAreas.removeAll { $0 == area }
        } else {
            selectedFocusAreas.append(area)
        }
    }

    func onSavePressed() {
        interactor.trackEvent(event: Event.saveTapped)
        Task {
            await saveSession()
        }
    }

    func onCancelPressed() {
        interactor.trackEvent(event: Event.cancelTapped)
        router.dismissScreen()
    }

    private func saveSession() async {
        isLoading = true
        errorMessage = nil

        do {
            let params = SessionEntryParams(
                date: date,
                duration: TimeInterval(durationMinutes * 60),
                sessionType: sessionType,
                academy: academy.isEmpty ? nil : academy,
                instructor: instructor.isEmpty ? nil : instructor,
                focusAreas: selectedFocusAreas,
                notes: notes.isEmpty ? nil : notes,
                preSessionMood: showMoodSection ? preSessionMood : nil,
                postSessionMood: showMoodSection ? postSessionMood : nil,
                roundsCount: roundsCount,
                whatWorkedWell: whatWorkedWell.isEmpty ? nil : whatWorkedWell,
                needsImprovement: needsImprovement.isEmpty ? nil : needsImprovement,
                keyInsights: keyInsights.isEmpty ? nil : keyInsights
            )
            let session = try await interactor.logSessionWithGamification(params)
            interactor.trackEvent(event: Event.saveSuccess(sessionId: session.id))
            interactor.playHaptic(option: .success)
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    var durationText: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

extension SessionEntryPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case saveTapped
        case saveSuccess(sessionId: String)
        case saveFail(error: Error)
        case cancelTapped

        var eventName: String {
            switch self {
            case .onAppear:     return "SessionEntryView_Appear"
            case .saveTapped:   return "SessionEntryView_Save_Tap"
            case .saveSuccess:  return "SessionEntryView_Save_Success"
            case .saveFail:     return "SessionEntryView_Save_Fail"
            case .cancelTapped: return "SessionEntryView_Cancel_Tap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .saveSuccess(sessionId: let sessionId):
                return ["session_id": sessionId]
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

struct SessionEntryDelegate {
    var eventParameters: [String: Any]? { nil }
}
