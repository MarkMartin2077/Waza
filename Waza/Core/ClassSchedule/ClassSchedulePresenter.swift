import SwiftUI

@Observable
@MainActor
class ClassSchedulePresenter {
    private let interactor: ClassScheduleInteractor
    private let router: ClassScheduleRouter
    let delegate: ClassSchedulePlanningDelegate

    private(set) var gyms: [GymLocationModel] = []
    private(set) var schedulesByGym: [String: [ClassScheduleModel]] = [:]

    init(interactor: ClassScheduleInteractor, router: ClassScheduleRouter, delegate: ClassSchedulePlanningDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
    }

    func loadData() {
        gyms = interactor.gyms
        let allSchedules = interactor.schedules
        schedulesByGym = Dictionary(grouping: allSchedules.filter { $0.isActive }, by: \.gymId)
    }

    func onAddGymTapped() {
        interactor.trackEvent(event: Event.addGymTapped)
        router.showGymSetupView(existingGym: nil) { [weak self] in
            self?.loadData()
        }
    }

    func onEditGymTapped(_ gym: GymLocationModel) {
        interactor.trackEvent(event: Event.editGymTapped)
        router.showGymSetupView(existingGym: gym) { [weak self] in
            self?.loadData()
        }
    }

    func onAddScheduleTapped(gymId: String) {
        interactor.trackEvent(event: Event.addScheduleTapped)
        router.showAddScheduleSheet(gymId: gymId, existingSchedule: nil) { [weak self] in
            self?.loadData()
        }
    }

    func onEditScheduleTapped(_ schedule: ClassScheduleModel) {
        interactor.trackEvent(event: Event.editScheduleTapped)
        router.showAddScheduleSheet(gymId: schedule.gymId, existingSchedule: schedule) { [weak self] in
            self?.loadData()
        }
    }

    func onDeleteScheduleTapped(_ schedule: ClassScheduleModel) {
        interactor.trackEvent(event: Event.deleteScheduleTapped)
        router.showAlert(.alert, title: "Delete Class?", subtitle: "This will remove \"\(schedule.name)\" from your schedule.") {
            AnyView(
                Group {
                    Button("Delete", role: .destructive) { [weak self] in
                        self?.onDeleteScheduleConfirmed(schedule)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
        }
    }

    private func onDeleteScheduleConfirmed(_ schedule: ClassScheduleModel) {
        interactor.trackEvent(event: Event.deleteScheduleConfirmed)
        do {
            try interactor.deleteSchedule(schedule)
            loadData()
        } catch {
            interactor.trackEvent(event: Event.deleteFail(error: error))
        }
    }
}

extension ClassSchedulePresenter {
    enum Event: LoggableEvent {
        case onAppear
        case addGymTapped
        case editGymTapped
        case addScheduleTapped
        case editScheduleTapped
        case deleteScheduleTapped
        case deleteScheduleConfirmed
        case deleteFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                 return "ClassScheduleView_Appear"
            case .addGymTapped:             return "ClassScheduleView_AddGym_Tap"
            case .editGymTapped:            return "ClassScheduleView_EditGym_Tap"
            case .addScheduleTapped:        return "ClassScheduleView_AddSchedule_Tap"
            case .editScheduleTapped:       return "ClassScheduleView_EditSchedule_Tap"
            case .deleteScheduleTapped:     return "ClassScheduleView_DeleteSchedule_Tap"
            case .deleteScheduleConfirmed:  return "ClassScheduleView_DeleteSchedule_Confirm"
            case .deleteFail:               return "ClassScheduleView_Delete_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .deleteFail(error: let error): return error.eventParameters
            default: return nil
            }
        }

        var type: LogType {
            switch self {
            case .deleteFail: return .severe
            default: return .analytic
            }
        }
    }
}

struct ClassSchedulePlanningDelegate {
    var eventParameters: [String: Any]? { nil }
}
