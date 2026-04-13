import XCTest

// MARK: - Waza UI Tests
//
// Flow-based tests — each test covers a meaningful user journey.
// Fewer app launches = faster suite, fewer simulator clones.
//
// Flows:
//   1. Onboarding — Welcome screen shows title, subtitle, and CTAs when signed out
//   2. Tab navigation — Signed-in user can navigate to all four tabs
//   3. Sessions — Tab shows data, "+" opens sheet, cancel dismisses it
//   4. Log session — Sheet opens with form sections, save button present

@MainActor
final class WazaUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    private func launchSignedOut() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        return app
    }

    private func launchSignedIn() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        return app
    }

    // MARK: - Onboarding Flow

    func testOnboardingFlow_signedOutShowsWelcomeWithCTAs() throws {
        let app = launchSignedOut()

        // Title and subtitle
        XCTAssertTrue(app.staticTexts["Waza"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Your BJJ journey, tracked."].exists)

        // CTAs
        XCTAssertTrue(app.buttons["StartButton"].exists)
        XCTAssertTrue(app.buttons["Already have an account? Sign In"].exists)
    }

    // MARK: - Tab Navigation Flow

    func testTabNavigation_canReachAllTabs() throws {
        let app = launchSignedIn()

        // Home tab is default — verify greeting exists
        let greeting = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Good' OR label CONTAINS 'Ready'")
        )
        XCTAssertTrue(greeting.firstMatch.waitForExistence(timeout: 5))

        // Navigate to Sessions
        let sessionsTab = app.descendants(matching: .any)["Sessions"]
        XCTAssertTrue(sessionsTab.waitForExistence(timeout: 5))
        sessionsTab.tap()
        XCTAssertTrue(app.navigationBars["Sessions"].waitForExistence(timeout: 5))

        // Navigate to Progress
        let progressTab = app.descendants(matching: .any)["Progress"]
        progressTab.tap()
        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 5))

        // Navigate to Profile
        let profileTab = app.descendants(matching: .any)["Profile"]
        profileTab.tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    // MARK: - Sessions Flow

    func testSessionsFlow_showsDataAndSupportsLogSession() throws {
        let app = launchSignedIn()

        // Navigate to Sessions tab
        let sessionsTab = app.descendants(matching: .any)["Sessions"]
        XCTAssertTrue(sessionsTab.waitForExistence(timeout: 5))
        sessionsTab.tap()
        XCTAssertTrue(app.navigationBars["Sessions"].waitForExistence(timeout: 5))

        // Seed data means "No Sessions Yet" should NOT appear
        XCTAssertFalse(app.staticTexts["No Sessions Yet"].exists)

        // Open log session sheet via "+" button
        let addButton = app.buttons["Log session"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Sheet opens
        let sheetTitle = app.navigationBars["Log Session"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 5))

        // Cancel dismisses back to Sessions
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Sessions"].waitForExistence(timeout: 5))
    }

    // MARK: - Log Session Form

    func testLogSessionForm_showsRequiredSections() throws {
        let app = launchSignedIn()

        // Navigate to Sessions > open sheet
        let sessionsTab = app.descendants(matching: .any)["Sessions"]
        XCTAssertTrue(sessionsTab.waitForExistence(timeout: 5))
        sessionsTab.tap()

        let addButton = app.buttons["Log session"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Verify form sections
        XCTAssertTrue(app.navigationBars["Log Session"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Session Type"].exists)
        XCTAssertTrue(app.staticTexts["Focus Areas"].exists)

        // Save button present
        let saveButton = app.descendants(matching: .any)["Save Session"]
        XCTAssertTrue(saveButton.exists)
    }
}
