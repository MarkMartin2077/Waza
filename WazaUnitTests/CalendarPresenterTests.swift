import Testing
import Foundation
@testable import Waza

// MARK: - Mocks

@MainActor
final class StubCalendarInteractor: CalendarInteractor {
    var sessions: [BJJSessionModel] = []
    var schedules: [ClassScheduleModel] = []
    var gymsById: [String: GymLocationModel] = [:]
    var buildCallCount = 0
    // Inject a fixed "now" so assertions about today/future don't drift with wall clock.
    var now: Date = Date()
    var calendar: Calendar = .current

    var allSessions: [BJJSessionModel] { sessions }

    func buildCalendarMonth(anchor: Date) -> [CalendarDayModel] {
        buildCallCount += 1
        return CalendarMonthBuilder.buildMonth(
            anchor: anchor,
            sessions: sessions,
            schedules: schedules,
            gymsById: gymsById,
            calendar: calendar,
            now: now
        )
    }

    func sessionsOn(date: Date) -> [BJJSessionModel] {
        let cal = Calendar.current
        return sessions.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    // GlobalInteractor
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {}
    func trackEvent(event: AnyLoggableEvent) {}
    func trackEvent(event: LoggableEvent) {}
    func trackScreenEvent(event: LoggableEvent) {}
    func playHaptic(option: HapticOption) {}
}

@MainActor
final class SpyCalendarRouter: CalendarRouter {
    private(set) var sessionDetailCalls: [BJJSessionModel] = []
    private(set) var checkInCalls: [(gym: GymLocationModel, schedule: ClassScheduleModel?)] = []
    private(set) var sessionEntryCalls = 0
    private(set) var dayDetailSheetCalls: [CalendarDayModel] = []
    private(set) var addScheduleCalls: [String] = []
    private(set) var gymSetupCalls = 0
    private(set) var gymPickerCalls: [[GymLocationModel]] = []
    private(set) var sessionsViewCalls = 0

    private(set) var lastSessionEntryOnDismiss: (() -> Void)?
    private(set) var lastAddScheduleOnDismiss: (() -> Void)?
    private(set) var lastGymSetupOnDismiss: (() -> Void)?
    private(set) var lastCheckInOnDismiss: (() -> Void)?
    private(set) var lastGymPickerOnSelect: ((String) -> Void)?

    var router: AnyRouter { fatalError("Router not used in unit tests") }

    func showSessionDetailView(session: BJJSessionModel) {
        sessionDetailCalls.append(session)
    }

    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?) {
        checkInCalls.append((gym, schedule))
        lastCheckInOnDismiss = onDismiss
    }

    private(set) var lastSessionEntryInitialDate: Date?

    func showSessionEntryView(onDismiss: (() -> Void)?) {
        sessionEntryCalls += 1
        lastSessionEntryInitialDate = nil
        lastSessionEntryOnDismiss = onDismiss
    }

    func showSessionEntryView(initialDate: Date?, onDismiss: (() -> Void)?) {
        sessionEntryCalls += 1
        lastSessionEntryInitialDate = initialDate
        lastSessionEntryOnDismiss = onDismiss
    }

    func showCalendarDayDetailSheet(day: CalendarDayModel, callbacks: CalendarDayDetailCallbacks) {
        dayDetailSheetCalls.append(day)
    }

    func showAddScheduleSheet(gymId: String, existingSchedule: ClassScheduleModel?, onDismiss: (() -> Void)?) {
        addScheduleCalls.append(gymId)
        lastAddScheduleOnDismiss = onDismiss
    }

    func showGymSetupView(existingGym: GymLocationModel?, onDismiss: (() -> Void)?) {
        gymSetupCalls += 1
        lastGymSetupOnDismiss = onDismiss
    }

    func showGymPickerForAddSchedule(gyms: [GymLocationModel], onSelect: @escaping @MainActor @Sendable (String) -> Void) {
        gymPickerCalls.append(gyms)
        lastGymPickerOnSelect = onSelect
    }

    func showSessionsView() {
        sessionsViewCalls += 1
    }
}

// MARK: - Helpers

@MainActor
struct CalendarPresenterHarness {
    let presenter: CalendarPresenter
    let interactor: StubCalendarInteractor
    let router: SpyCalendarRouter
}

@MainActor
private func makeHarness(
    sessions: [BJJSessionModel] = [],
    schedules: [ClassScheduleModel] = [],
    gyms: [GymLocationModel] = []
) -> CalendarPresenterHarness {
    let interactor = StubCalendarInteractor()
    interactor.sessions = sessions
    interactor.schedules = schedules
    interactor.gymsById = Dictionary(uniqueKeysWithValues: gyms.map { ($0.gymId, $0) })
    let router = SpyCalendarRouter()
    let presenter = CalendarPresenter(interactor: interactor, router: router)
    return CalendarPresenterHarness(presenter: presenter, interactor: interactor, router: router)
}

private let cal = Calendar.current

private func makeDay(
    date: Date = Date(),
    sessions: [BJJSessionModel] = [],
    scheduled: [ScheduledClassOccurrence] = [],
    isToday: Bool = false,
    isFuture: Bool = false
) -> CalendarDayModel {
    CalendarDayModel(
        id: ISO8601DateFormatter().string(from: date),
        date: cal.startOfDay(for: date),
        sessions: sessions,
        scheduledOccurrences: scheduled,
        isToday: isToday,
        isInDisplayedMonth: true,
        isFuture: isFuture
    )
}

private func makeOccurrence(at date: Date, gymId: String = "gym-1") -> ScheduledClassOccurrence {
    let gym = GymLocationModel(gymId: gymId, name: "Gym")
    let schedule = ClassScheduleModel(
        scheduleId: "sched-1",
        gymId: gymId,
        name: "Class",
        dayOfWeek: cal.component(.weekday, from: date),
        startHour: cal.component(.hour, from: date),
        startMinute: cal.component(.minute, from: date),
        durationMinutes: 60,
        isActive: true
    )
    return ScheduledClassOccurrence(
        id: "occ-1",
        schedule: schedule,
        gym: gym,
        occursAt: date
    )
}

// MARK: - Tests

@Suite("CalendarPresenter - Lifecycle & Navigation") @MainActor
struct CalendarPresenterLifecycleTests {

    @Test("onViewAppear loads the current month")
    func onViewAppear_loadsCurrentMonth() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        #expect(harness.interactor.buildCallCount == 1)
        #expect(harness.presenter.days.count == 42)
    }

    @Test("onViewAppear invalidates cache so new sessions reflect immediately")
    func onViewAppear_invalidatesCache() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        harness.presenter.onViewAppear()
        #expect(harness.interactor.buildCallCount == 2)
    }

    @Test("onNextMonth advances the anchor by one month and rebuilds")
    func onNextMonth_advancesAnchor() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        let before = harness.presenter.displayedMonthAnchor
        harness.presenter.onNextMonth()
        let diff = cal.dateComponents([.month], from: before, to: harness.presenter.displayedMonthAnchor).month ?? 0
        #expect(diff == 1)
        #expect(harness.interactor.buildCallCount == 2)
    }

    @Test("onPrevMonth rewinds the anchor by one month")
    func onPrevMonth_rewindsAnchor() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        let before = harness.presenter.displayedMonthAnchor
        harness.presenter.onPrevMonth()
        let diff = cal.dateComponents([.month], from: harness.presenter.displayedMonthAnchor, to: before).month ?? 0
        #expect(diff == 1)
    }

    @Test("Paging back to a cached month skips the rebuild")
    func pagingBack_usesCache() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        harness.presenter.onNextMonth()
        harness.presenter.onPrevMonth()
        #expect(harness.interactor.buildCallCount == 2)
    }
}

@Suite("CalendarPresenter - Day Tap Routing") @MainActor
struct CalendarPresenterDayTapTests {

    @Test("Tapping a day with exactly one session pushes SessionDetail")
    func singleSession_opensDetail() {
        let session = BJJSessionModel(sessionId: "s1", sessionType: .gi)
        let harness = makeHarness()
        let day = makeDay(sessions: [session])

        harness.presenter.onDayTapped(day)

        #expect(harness.router.sessionDetailCalls.count == 1)
        #expect(harness.router.sessionDetailCalls.first?.sessionId == "s1")
        #expect(harness.router.dayDetailSheetCalls.isEmpty)
    }

    @Test("Tapping an old empty past day (>14 days) is a no-op")
    func oldEmptyPast_isNoOp() {
        let harness = makeHarness()
        let oldDate = cal.date(byAdding: .day, value: -30, to: Date())!
        let day = makeDay(date: oldDate, isFuture: false)

        harness.presenter.onDayTapped(day)

        #expect(harness.router.sessionDetailCalls.isEmpty)
        #expect(harness.router.dayDetailSheetCalls.isEmpty)
        #expect(harness.router.sessionEntryCalls == 0)
    }

    @Test("Tapping a future day with one scheduled class inside check-in window opens CheckIn")
    func futureInWindow_opensCheckIn() {
        let harness = makeHarness()
        let now = Date()
        let occursAt = now.addingTimeInterval(10 * 60)
        let occurrence = makeOccurrence(at: occursAt)
        let day = makeDay(
            date: now.addingTimeInterval(10 * 60),
            scheduled: [occurrence],
            isFuture: true
        )

        harness.presenter.onDayTapped(day)

        #expect(harness.router.checkInCalls.count == 1)
        #expect(harness.router.dayDetailSheetCalls.isEmpty)
    }

    @Test("Tapping a future empty day (no schedule) shows the day detail sheet")
    func futureEmpty_showsSheet() {
        let harness = makeHarness()
        let future = cal.date(byAdding: .day, value: 5, to: Date())!
        let day = makeDay(date: future, isFuture: true)

        harness.presenter.onDayTapped(day)

        #expect(harness.router.dayDetailSheetCalls.count == 1)
    }

    @Test("Tapping a recent empty past day (within 14 days) shows the day detail sheet")
    func recentEmptyPast_showsSheet() {
        let harness = makeHarness()
        let recent = cal.date(byAdding: .day, value: -3, to: Date())!
        let day = makeDay(date: recent, isFuture: false)

        harness.presenter.onDayTapped(day)

        #expect(harness.router.dayDetailSheetCalls.count == 1)
    }
}

@Suite("CalendarPresenter - Pending Actions (Sheet CTAs)") @MainActor
struct CalendarPresenterPendingActionTests {

    @Test("onLogSessionTapped queues logSession; onDismissDayDetail runs it")
    func logSession_queuesAndRuns() {
        let harness = makeHarness()

        harness.presenter.onLogSessionTapped()
        #expect(harness.router.sessionEntryCalls == 0)

        harness.presenter.onDismissDayDetail()
        #expect(harness.router.sessionEntryCalls == 1)
    }

    @Test("onAddScheduleTapped with no gyms routes to Gym Setup, not Add Schedule")
    func addSchedule_noGyms_routesToGymSetup() {
        let harness = makeHarness(gyms: [])

        harness.presenter.onAddScheduleTapped()
        harness.presenter.onDismissDayDetail()

        #expect(harness.router.gymSetupCalls == 1)
        #expect(harness.router.addScheduleCalls.isEmpty)
    }

    @Test("onAddScheduleTapped with gyms routes to Add Schedule")
    func addSchedule_withGyms_routesToAddSchedule() {
        let gym = GymLocationModel(gymId: "gym-7", name: "Gym 7")
        let harness = makeHarness(gyms: [gym])

        harness.presenter.onAddScheduleTapped()
        harness.presenter.onDismissDayDetail()

        #expect(harness.router.addScheduleCalls == ["gym-7"])
        #expect(harness.router.gymSetupCalls == 0)
    }

    @Test("onSessionTapped queues openSession; onDismissDayDetail pushes detail")
    func sessionTapped_queuesAndRuns() {
        let harness = makeHarness()
        let session = BJJSessionModel(sessionId: "s-99")

        harness.presenter.onSessionTapped(session)
        #expect(harness.router.sessionDetailCalls.isEmpty)

        harness.presenter.onDismissDayDetail()
        #expect(harness.router.sessionDetailCalls.first?.sessionId == "s-99")
    }

    @Test("onOccurrenceTapped inside window queues check-in")
    func occurrenceTapped_insideWindow_queuesCheckIn() {
        let harness = makeHarness()
        let occurrence = makeOccurrence(at: Date().addingTimeInterval(5 * 60))

        harness.presenter.onOccurrenceTapped(occurrence)
        harness.presenter.onDismissDayDetail()

        #expect(harness.router.checkInCalls.count == 1)
    }

    @Test("onOccurrenceTapped outside window is a no-op")
    func occurrenceTapped_outsideWindow_isNoOp() {
        let harness = makeHarness()
        let occurrence = makeOccurrence(at: Date().addingTimeInterval(2 * 60 * 60))

        harness.presenter.onOccurrenceTapped(occurrence)
        harness.presenter.onDismissDayDetail()

        #expect(harness.router.checkInCalls.isEmpty)
    }

    @Test("onDismissDayDetail with no pending action is a no-op for routing")
    func dismissWithoutPending_isNoOp() {
        let harness = makeHarness()

        harness.presenter.onDismissDayDetail()

        #expect(harness.router.sessionEntryCalls == 0)
        #expect(harness.router.addScheduleCalls.isEmpty)
        #expect(harness.router.sessionDetailCalls.isEmpty)
        #expect(harness.router.checkInCalls.isEmpty)
        #expect(harness.router.gymSetupCalls == 0)
    }

    @Test("Pending action is cleared after one run (not double-fired)")
    func pendingAction_clearedAfterRun() {
        let harness = makeHarness()

        harness.presenter.onLogSessionTapped()
        harness.presenter.onDismissDayDetail()
        harness.presenter.onDismissDayDetail()

        #expect(harness.router.sessionEntryCalls == 1)
    }
}

@Suite("CalendarPresenter - Cache Invalidation After Writes") @MainActor
struct CalendarPresenterReloadTests {

    @Test("Session save callback invalidates cache and rebuilds the current month")
    func sessionSave_rebuildsMonth() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        harness.presenter.onLogSessionTapped()
        harness.presenter.onDismissDayDetail()

        harness.interactor.sessions = [BJJSessionModel(sessionId: "new")]
        harness.router.lastSessionEntryOnDismiss?()

        let newCell = harness.presenter.days.first(where: { $0.sessions.contains(where: { $0.sessionId == "new" }) })
        #expect(newCell != nil)
    }

    @Test("Add schedule callback invalidates cache")
    func addSchedule_rebuildsMonth() {
        let gym = GymLocationModel(gymId: "g", name: "g")
        let harness = makeHarness(gyms: [gym])
        harness.presenter.onViewAppear()
        harness.presenter.onAddScheduleTapped()
        harness.presenter.onDismissDayDetail()
        let before = harness.interactor.buildCallCount

        harness.router.lastAddScheduleOnDismiss?()
        #expect(harness.interactor.buildCallCount == before + 1)
    }

    @Test("Gym setup callback invalidates cache")
    func gymSetup_rebuildsMonth() {
        let harness = makeHarness(gyms: [])
        harness.presenter.onViewAppear()
        harness.presenter.onAddScheduleTapped()
        harness.presenter.onDismissDayDetail()
        let before = harness.interactor.buildCallCount

        harness.router.lastGymSetupOnDismiss?()
        #expect(harness.interactor.buildCallCount == before + 1)
    }

    @Test("Check-in callback invalidates cache")
    func checkIn_rebuildsMonth() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()
        let occurrence = makeOccurrence(at: Date().addingTimeInterval(5 * 60))
        harness.presenter.onOccurrenceTapped(occurrence)
        harness.presenter.onDismissDayDetail()
        let before = harness.interactor.buildCallCount

        harness.router.lastCheckInOnDismiss?()
        #expect(harness.interactor.buildCallCount == before + 1)
    }

    @Test("Full flow — tap empty day → log session → new hanko reflected on dismiss")
    func fullFlow_tapLogDismiss_hankoAppears() {
        let harness = makeHarness()
        harness.presenter.onViewAppear()

        // 1. Tap empty past day → sheet
        let past = cal.date(byAdding: .day, value: -3, to: Date())!
        let day = makeDay(date: past)
        harness.presenter.onDayTapped(day)
        #expect(harness.router.dayDetailSheetCalls.count == 1)

        // 2. User taps "Log a session here" → queues action
        harness.presenter.onLogSessionTapped()

        // 3. Sheet dismisses → runs queued action, opens session entry
        harness.presenter.onDismissDayDetail()
        #expect(harness.router.sessionEntryCalls == 1)

        // 4. User saves session → onDismiss reloads. Simulate a new session appearing.
        harness.interactor.sessions = [BJJSessionModel(sessionId: "new-one", date: past)]
        harness.router.lastSessionEntryOnDismiss?()

        // 5. Calendar now shows the new session (cache invalidated, day rebuilt).
        let updatedDay = harness.presenter.days.first(where: { $0.sessions.contains(where: { $0.sessionId == "new-one" }) })
        #expect(updatedDay != nil)
    }
}
