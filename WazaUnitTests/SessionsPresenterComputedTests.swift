import Testing
import Foundation
@testable import Waza

// MARK: - Computed Property Tests

@Suite("SessionsPresenter - Computed Properties") @MainActor
struct SessionsPresenterComputedTests {

    @Test("hasActiveFilters is false with no filters")
    func hasActiveFiltersFalse() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // THEN
        #expect(presenter.hasActiveFilters == false)
    }

    @Test("hasActiveFilters is true when type filter is set")
    func hasActiveFiltersType() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onSessionTypeToggled(.gi)

        // THEN
        #expect(presenter.hasActiveFilters == true)
    }

    @Test("hasActiveFilters is true when academy filter is set")
    func hasActiveFiltersAcademy() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onAcademySelected("Gracie Barra")

        // THEN
        #expect(presenter.hasActiveFilters == true)
    }

    @Test("hasActiveFilters is true when mood filter is set")
    func hasActiveFiltersMood() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onMoodSelected(5)

        // THEN
        #expect(presenter.hasActiveFilters == true)
    }

    @Test("isSearching is false for empty search text")
    func isSearchingFalse() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // THEN
        #expect(presenter.isSearching == false)
    }

    @Test("isSearching is true when search text is present")
    func isSearchingTrue() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.searchText = "guard"

        // THEN
        #expect(presenter.isSearching == true)
    }

    @Test("filteredCount reflects the number of filtered results")
    func filteredCount() {
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
        #expect(presenter.filteredCount == 2)
        #expect(presenter.totalCount == 3)
    }

    @Test("sessionTypeFilterLabel shows 'Type' when no filter")
    func typeFilterLabelDefault() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // THEN
        #expect(presenter.sessionTypeFilterLabel == "Type")
    }

    @Test("sessionTypeFilterLabel shows display name for single type")
    func typeFilterLabelSingle() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onSessionTypeToggled(.noGi)

        // THEN
        #expect(presenter.sessionTypeFilterLabel == "No-Gi")
    }

    @Test("sessionTypeFilterLabel shows count for multiple types")
    func typeFilterLabelMultiple() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onSessionTypeToggled(.gi)
        presenter.onSessionTypeToggled(.noGi)

        // THEN
        #expect(presenter.sessionTypeFilterLabel == "2 Types")
    }

    @Test("academyFilterLabel shows 'Gym' when no filter")
    func academyFilterLabelDefault() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // THEN
        #expect(presenter.academyFilterLabel == "Gym")
    }

    @Test("academyFilterLabel shows selected academy name")
    func academyFilterLabelSelected() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onAcademySelected("Gracie Barra")

        // THEN
        #expect(presenter.academyFilterLabel == "Gracie Barra")
    }

    @Test("moodFilterLabel shows 'Mood' when no filter")
    func moodFilterLabelDefault() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // THEN
        #expect(presenter.moodFilterLabel == "Mood")
    }

    @Test("moodFilterLabel shows emoji for selected mood")
    func moodFilterLabelSelected() {
        // GIVEN
        let (presenter, _) = makePresenter(sessions: [])

        // WHEN
        presenter.onMoodSelected(5)

        // THEN
        #expect(presenter.moodFilterLabel == "🔥")
    }
}
