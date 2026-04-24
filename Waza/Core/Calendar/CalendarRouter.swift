import SwiftUI

struct CalendarDayDetailCallbacks {
    let onSessionTap: (BJJSessionModel) -> Void
    let onOccurrenceTap: (ScheduledClassOccurrence) -> Void
    let onAddSchedule: () -> Void
    let onLogSession: () -> Void
    let onViewAllSessions: () -> Void
    let onDismiss: () -> Void
}

@MainActor
protocol CalendarRouter: GlobalRouter {
    func showSessionDetailView(session: BJJSessionModel)
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?)
    func showSessionEntryView(onDismiss: (() -> Void)?)
    func showCalendarDayDetailSheet(day: CalendarDayModel, callbacks: CalendarDayDetailCallbacks)
    func showAddScheduleSheet(gymId: String, existingSchedule: ClassScheduleModel?, onDismiss: (() -> Void)?)
    func showGymSetupView(existingGym: GymLocationModel?, onDismiss: (() -> Void)?)
    func showGymPickerForAddSchedule(gyms: [GymLocationModel], onSelect: @escaping @MainActor @Sendable (String) -> Void)
    func showSessionsView()
}

extension CoreRouter: CalendarRouter {

    func showCalendarDayDetailSheet(day: CalendarDayModel, callbacks: CalendarDayDetailCallbacks) {
        router.showScreen(.sheet, onDismiss: callbacks.onDismiss) { _ in
            CalendarDayDetailSheet(day: day, callbacks: callbacks)
        }
    }

    func showGymPickerForAddSchedule(gyms: [GymLocationModel], onSelect: @escaping @MainActor @Sendable (String) -> Void) {
        showAlert(.alert, title: "Choose a gym", subtitle: "Where is this class held?") {
            AnyView(
                ForEach(gyms, id: \.gymId) { gym in
                    Button(gym.name) { onSelect(gym.gymId) }
                }
            )
        }
    }

    func showSessionsView() {
        router.showScreen(.push) { router in
            builder.sessionsView(router: router)
        }
    }

}
