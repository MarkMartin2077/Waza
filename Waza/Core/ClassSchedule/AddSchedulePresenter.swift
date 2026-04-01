import SwiftUI

@Observable
@MainActor
class AddSchedulePresenter {
    private let interactor: any AddScheduleInteractor
    private let router: any AddScheduleRouter
    let delegate: AddScheduleDelegate

    // Form state
    var name: String = ""
    var dayOfWeek: Int = 2
    var startHour: Int = 19
    var startMinute: Int = 0
    var durationMinutes: Int = 60
    var sessionType: SessionType = .gi
    var reminderMinutes: Int = 30

    var isSaveDisabled: Bool {
        name.isEmpty
    }

    let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    init(interactor: any AddScheduleInteractor, router: any AddScheduleRouter, delegate: AddScheduleDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        populateFromExisting()
    }

    func onCancelTapped() {
        interactor.trackEvent(event: Event.cancelTapped)
        router.dismissScreen()
    }

    func onSaveTapped() {
        interactor.trackEvent(event: Event.saveTapped)
        save()
    }

    private func populateFromExisting() {
        guard let schedule = delegate.existingSchedule else { return }
        name = schedule.name
        dayOfWeek = schedule.dayOfWeek
        startHour = schedule.startHour
        startMinute = schedule.startMinute
        durationMinutes = schedule.durationMinutes
        sessionType = schedule.sessionType
        reminderMinutes = schedule.reminderMinutesBefore
    }

    private func save() {
        do {
            if let existing = delegate.existingSchedule {
                var updated = existing
                updated.name = name
                updated.dayOfWeek = dayOfWeek
                updated.startHour = startHour
                updated.startMinute = startMinute
                updated.durationMinutes = durationMinutes
                updated.sessionType = sessionType
                updated.reminderMinutesBefore = reminderMinutes
                try interactor.updateSchedule(updated)
            } else {
                let params = AddScheduleParams(
                    gymId: delegate.gymId,
                    name: name,
                    dayOfWeek: dayOfWeek,
                    startHour: startHour,
                    startMinute: startMinute,
                    durationMinutes: durationMinutes,
                    sessionType: sessionType,
                    reminderMinutesBefore: reminderMinutes
                )
                try interactor.addSchedule(params)
            }
            if reminderMinutes > 0 {
                Task { try? await interactor.requestPushAuthorization() }
            }
            interactor.trackEvent(event: Event.saveSuccess)
            delegate.onSaved?()
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }
}

extension AddSchedulePresenter {
    enum Event: LoggableEvent {
        case onAppear
        case saveTapped
        case saveSuccess
        case saveFail(error: Error)
        case cancelTapped

        var eventName: String {
            switch self {
            case .onAppear:     return "AddScheduleView_Appear"
            case .saveTapped:   return "AddScheduleView_Save_Tap"
            case .saveSuccess:  return "AddScheduleView_Save_Success"
            case .saveFail:     return "AddScheduleView_Save_Fail"
            case .cancelTapped: return "AddScheduleView_Cancel_Tap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .saveFail(error: let error): return error.eventParameters
            default: return nil
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

struct AddScheduleDelegate {
    let gymId: String
    let existingSchedule: ClassScheduleModel?
    let onSaved: (() -> Void)?

    init(gymId: String, existingSchedule: ClassScheduleModel? = nil, onSaved: (() -> Void)? = nil) {
        self.gymId = gymId
        self.existingSchedule = existingSchedule
        self.onSaved = onSaved
    }
}
