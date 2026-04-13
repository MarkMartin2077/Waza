import Testing
import Foundation
@testable import Waza

// MARK: - Test Mocks

@MainActor
final class StubSessionsInteractor: SessionsInteractor {
    var sessions: [BJJSessionModel] = []

    var currentBeltEnum: BJJBelt { .blue }
    var allSessions: [BJJSessionModel] { sessions }
    var sessionStats: SessionStats { .empty }
    var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)? { nil }
    var gyms: [GymLocationModel] { [] }
    var schedules: [ClassScheduleModel] { [] }
    var currentStreakData: CurrentStreakData { .mockEmpty() }

    func deleteSession(_ session: BJJSessionModel) throws {}
    func updateWidgetData(_ data: WazaWidgetData) {}

    // GlobalInteractor
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {}
    func trackEvent(event: AnyLoggableEvent) {}
    func trackEvent(event: LoggableEvent) {}
    func trackScreenEvent(event: LoggableEvent) {}
    func playHaptic(option: HapticOption) {}
}

@MainActor
struct StubSessionsRouter: SessionsRouter {
    var router: AnyRouter { fatalError("Router not used in unit tests") }
    func showSessionDetailView(session: BJJSessionModel) {}
    func showSessionEntryView(onDismiss: (() -> Void)?) {}
    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod, onDismiss: (() -> Void)?) {}
}

// MARK: - Helpers

@MainActor
func makePresenter(sessions: [BJJSessionModel] = []) -> (SessionsPresenter, StubSessionsInteractor) {
    let interactor = StubSessionsInteractor()
    interactor.sessions = sessions
    let presenter = SessionsPresenter(
        router: StubSessionsRouter(),
        interactor: interactor
    )
    return (presenter, interactor)
}

private let cal = Calendar.current

private func daysAgo(_ days: Int) -> Date {
    cal.date(byAdding: .day, value: -days, to: Date()) ?? Date()
}

private func monthsAgo(_ months: Int) -> Date {
    cal.date(byAdding: .month, value: -months, to: Date()) ?? Date()
}

// MARK: - Search Tests

@Suite("SessionsPresenter - Search") @MainActor
struct SessionsPresenterSearchTests {

    @Test("Search matches focus areas (techniques)")
    func searchFocusAreas() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", focusAreas: ["Guard Passing", "Back Takes"]),
            BJJSessionModel(sessionId: "2", focusAreas: ["Takedowns"]),
            BJJSessionModel(sessionId: "3", focusAreas: ["Sweeps"])
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "guard"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches notes text")
    func searchNotes() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", notes: "Great drilling session on leg drags"),
            BJJSessionModel(sessionId: "2", notes: "Worked on takedowns")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "leg drag"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches whatWorkedWell text")
    func searchWhatWorkedWell() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", whatWorkedWell: "Pressure passing worked great"),
            BJJSessionModel(sessionId: "2", whatWorkedWell: "Closed guard retention")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "pressure"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches needsImprovement text")
    func searchNeedsImprovement() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", needsImprovement: "Escapes from mount"),
            BJJSessionModel(sessionId: "2", needsImprovement: "Grip fighting")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "mount"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches keyInsights text")
    func searchKeyInsights() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", keyInsights: "Hip angle is key for the leg drag"),
            BJJSessionModel(sessionId: "2", keyInsights: "Keep elbows tight")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "hip angle"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches academy name")
    func searchAcademy() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", academy: "Gracie Barra"),
            BJJSessionModel(sessionId: "2", academy: "10th Planet")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "gracie"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches instructor name")
    func searchInstructor() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", instructor: "Professor Silva"),
            BJJSessionModel(sessionId: "2", instructor: "Coach Johnson")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "silva"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search matches session type display name")
    func searchSessionType() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .openMat),
            BJJSessionModel(sessionId: "2", sessionType: .gi)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "open mat"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Search is case insensitive")
    func searchCaseInsensitive() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", focusAreas: ["Guard Passing"])
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "GUARD PASSING"

        // THEN
        #expect(presenter.filteredSessions.count == 1)
    }

    @Test("Search returns all sessions when text is empty")
    func searchEmptyText() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1"),
            BJJSessionModel(sessionId: "2")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = ""

        // THEN
        #expect(presenter.filteredSessions.count == 2)
    }

    @Test("Search returns all sessions when text is only whitespace")
    func searchWhitespaceOnly() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1"),
            BJJSessionModel(sessionId: "2")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "   "

        // THEN
        #expect(presenter.filteredSessions.count == 2)
    }

    @Test("Search returns empty when no match is found")
    func searchNoMatch() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", focusAreas: ["Guard"], notes: "Good session")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "zzzzzzz"

        // THEN
        #expect(presenter.filteredSessions.isEmpty)
    }
}

// MARK: - Type Filter Tests

@Suite("SessionsPresenter - Type Filter") @MainActor
struct SessionsPresenterTypeFilterTests {

    @Test("Filtering by a single session type returns only matching sessions")
    func filterSingleType() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi),
            BJJSessionModel(sessionId: "2", sessionType: .noGi),
            BJJSessionModel(sessionId: "3", sessionType: .gi)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onSessionTypeToggled(.gi)

        // THEN
        #expect(presenter.filteredSessions.count == 2)
        #expect(presenter.filteredSessions.allSatisfy { $0.sessionType == .gi })
    }

    @Test("Filtering by multiple session types returns sessions matching any selected type")
    func filterMultipleTypes() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi),
            BJJSessionModel(sessionId: "2", sessionType: .noGi),
            BJJSessionModel(sessionId: "3", sessionType: .drilling)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onSessionTypeToggled(.gi)
        presenter.onSessionTypeToggled(.noGi)

        // THEN
        #expect(presenter.filteredSessions.count == 2)
    }

    @Test("Toggling a type off removes it from the filter")
    func toggleTypeOff() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi),
            BJJSessionModel(sessionId: "2", sessionType: .noGi)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onSessionTypeToggled(.gi)
        #expect(presenter.filteredSessions.count == 1)

        presenter.onSessionTypeToggled(.gi) // toggle off

        // THEN
        #expect(presenter.filteredSessions.count == 2)
    }

    @Test("No type filter returns all sessions")
    func noTypeFilter() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi),
            BJJSessionModel(sessionId: "2", sessionType: .noGi)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // THEN
        #expect(presenter.filteredSessions.count == 2)
        #expect(presenter.selectedSessionTypes.isEmpty)
    }
}

// MARK: - Academy Filter Tests

@Suite("SessionsPresenter - Academy Filter") @MainActor
struct SessionsPresenterAcademyFilterTests {

    @Test("Filtering by academy returns only sessions at that academy")
    func filterByAcademy() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", academy: "Gracie Barra"),
            BJJSessionModel(sessionId: "2", academy: "10th Planet"),
            BJJSessionModel(sessionId: "3", academy: "Gracie Barra")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onAcademySelected("Gracie Barra")

        // THEN
        #expect(presenter.filteredSessions.count == 2)
        #expect(presenter.filteredSessions.allSatisfy { $0.academy == "Gracie Barra" })
    }

    @Test("Clearing academy filter returns all sessions")
    func clearAcademyFilter() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", academy: "Gracie Barra"),
            BJJSessionModel(sessionId: "2", academy: "10th Planet")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onAcademySelected("Gracie Barra")
        #expect(presenter.filteredSessions.count == 1)
        presenter.onAcademySelected(nil)

        // THEN
        #expect(presenter.filteredSessions.count == 2)
    }

    @Test("availableAcademies returns unique sorted academy names")
    func availableAcademies() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", academy: "Gracie Barra"),
            BJJSessionModel(sessionId: "2", academy: "10th Planet"),
            BJJSessionModel(sessionId: "3", academy: "Gracie Barra"),
            BJJSessionModel(sessionId: "4", academy: nil),
            BJJSessionModel(sessionId: "5", academy: "Alliance")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // THEN
        #expect(presenter.availableAcademies == ["10th Planet", "Alliance", "Gracie Barra"])
    }

    @Test("availableAcademies excludes empty strings")
    func availableAcademiesExcludesEmpty() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", academy: ""),
            BJJSessionModel(sessionId: "2", academy: "Gracie Barra")
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // THEN
        #expect(presenter.availableAcademies == ["Gracie Barra"])
    }
}

// MARK: - Mood Filter Tests

@Suite("SessionsPresenter - Mood Filter") @MainActor
struct SessionsPresenterMoodFilterTests {

    @Test("Filtering by mood matches pre-session mood")
    func filterByPreMood() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", preSessionMood: 5, postSessionMood: 3),
            BJJSessionModel(sessionId: "2", preSessionMood: 2, postSessionMood: 2)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onMoodSelected(5)

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Filtering by mood matches post-session mood")
    func filterByPostMood() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", preSessionMood: 2, postSessionMood: 5),
            BJJSessionModel(sessionId: "2", preSessionMood: 3, postSessionMood: 3)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onMoodSelected(5)

        // THEN
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Clearing mood filter returns all sessions")
    func clearMoodFilter() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", preSessionMood: 5),
            BJJSessionModel(sessionId: "2", preSessionMood: 3)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onMoodSelected(5)
        #expect(presenter.filteredSessions.count == 1)
        presenter.onMoodSelected(nil)

        // THEN
        #expect(presenter.filteredSessions.count == 2)
    }
}

// MARK: - Combined Filters Tests

@Suite("SessionsPresenter - Combined Filters") @MainActor
struct SessionsPresenterCombinedFilterTests {

    @Test("Search combined with type filter narrows results")
    func searchPlusTypeFilter() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi, focusAreas: ["Guard"]),
            BJJSessionModel(sessionId: "2", sessionType: .gi, focusAreas: ["Takedowns"]),
            BJJSessionModel(sessionId: "3", sessionType: .noGi, focusAreas: ["Guard"])
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.searchText = "guard"
        presenter.onSessionTypeToggled(.gi)

        // THEN — only session 1 matches both search and type filter
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("All three filters combine to narrow results")
    func allFiltersCombine() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi, academy: "Gracie Barra", preSessionMood: 5),
            BJJSessionModel(sessionId: "2", sessionType: .gi, academy: "Gracie Barra", preSessionMood: 3),
            BJJSessionModel(sessionId: "3", sessionType: .noGi, academy: "Gracie Barra", preSessionMood: 5),
            BJJSessionModel(sessionId: "4", sessionType: .gi, academy: "10th Planet", preSessionMood: 5)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN
        presenter.onSessionTypeToggled(.gi)
        presenter.onAcademySelected("Gracie Barra")
        presenter.onMoodSelected(5)

        // THEN — only session 1 matches all three filters
        #expect(presenter.filteredSessions.count == 1)
        #expect(presenter.filteredSessions.first?.sessionId == "1")
    }

    @Test("Clear filters resets all filters at once")
    func clearAllFilters() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", sessionType: .gi, academy: "GB", preSessionMood: 5),
            BJJSessionModel(sessionId: "2", sessionType: .noGi, academy: "10P", preSessionMood: 3)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)
        presenter.onSessionTypeToggled(.gi)
        presenter.onAcademySelected("GB")
        presenter.onMoodSelected(5)
        #expect(presenter.filteredSessions.count == 1)

        // WHEN
        presenter.onClearFilters()

        // THEN
        #expect(presenter.filteredSessions.count == 2)
        #expect(presenter.selectedSessionTypes.isEmpty)
        #expect(presenter.selectedAcademy == nil)
        #expect(presenter.selectedMood == nil)
        #expect(presenter.hasActiveFilters == false)
    }
}

// MARK: - Grouping Tests

@Suite("SessionsPresenter - Grouping") @MainActor
struct SessionsPresenterGroupingTests {

    @Test("Sessions are grouped by month and year")
    func groupsByMonth() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", date: daysAgo(1)),     // this month
            BJJSessionModel(sessionId: "2", date: daysAgo(3)),     // this month
            BJJSessionModel(sessionId: "3", date: monthsAgo(1))   // last month
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // THEN
        let groups = presenter.groupedSessions
        #expect(groups.count == 2)
    }

    @Test("Groups are sorted newest first")
    func groupsSortedNewestFirst() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", date: monthsAgo(2)),
            BJJSessionModel(sessionId: "2", date: daysAgo(1)),
            BJJSessionModel(sessionId: "3", date: monthsAgo(1))
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // THEN
        let groups = presenter.groupedSessions
        #expect(groups.count == 3)
        // First group should be the most recent month
        #expect(groups.first?.sessions.first?.sessionId == "2")
    }

    @Test("Each group contains the correct sessions")
    func groupsContainCorrectSessions() {
        // GIVEN
        let thisMonth1 = BJJSessionModel(sessionId: "a", date: daysAgo(1))
        let thisMonth2 = BJJSessionModel(sessionId: "b", date: daysAgo(2))
        let lastMonth1 = BJJSessionModel(sessionId: "c", date: monthsAgo(1))
        let (presenter, _) = makePresenter(sessions: [thisMonth1, thisMonth2, lastMonth1])

        // THEN
        let groups = presenter.groupedSessions
        let newestGroup = groups.first!
        #expect(newestGroup.sessions.count == 2)
        #expect(newestGroup.sessions.contains { $0.sessionId == "a" })
        #expect(newestGroup.sessions.contains { $0.sessionId == "b" })
    }

    @Test("Empty sessions produce empty groups")
    func emptySessionsEmptyGroups() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // THEN
        #expect(presenter.groupedSessions.isEmpty)
    }

    @Test("Filtered sessions affect grouping")
    func filteredSessionsAffectGrouping() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", date: daysAgo(1), sessionType: .gi),
            BJJSessionModel(sessionId: "2", date: daysAgo(2), sessionType: .noGi),
            BJJSessionModel(sessionId: "3", date: monthsAgo(1), sessionType: .gi)
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // WHEN — filter to only Gi sessions
        presenter.onSessionTypeToggled(.gi)

        // THEN — only months with Gi sessions appear
        let groups = presenter.groupedSessions
        let totalSessions = groups.reduce(0) { $0 + $1.sessions.count }
        #expect(totalSessions == 2)
    }

    @Test("Group title matches month and year format")
    func groupTitleFormat() {
        // GIVEN
        let sessions = [
            BJJSessionModel(sessionId: "1", date: daysAgo(1))
        ]
        let (presenter, _) = makePresenter(sessions: sessions)

        // THEN
        let title = presenter.groupedSessions.first?.title ?? ""
        // Title should be like "April 2026" — contains the current month name
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let expected = formatter.string(from: daysAgo(1))
        #expect(title == expected)
    }
}
