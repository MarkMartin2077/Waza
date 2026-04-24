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

        // Navigate to Train → Calendar is the default segment
        let trainTab = app.descendants(matching: .any)["Train"]
        XCTAssertTrue(trainTab.waitForExistence(timeout: 5))
        trainTab.tap()
        XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 5))

        // Navigate to Progress
        let progressTab = app.descendants(matching: .any)["Progress"]
        progressTab.tap()
        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 5))

        // Navigate to Profile
        let profileTab = app.descendants(matching: .any)["Profile"]
        profileTab.tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    // MARK: - Train Tab — Calendar ↔ Techniques

    func testTrainTab_canToggleBetweenCalendarAndTechniques() throws {
        let app = launchSignedIn()

        let trainTab = app.descendants(matching: .any)["Train"]
        XCTAssertTrue(trainTab.waitForExistence(timeout: 5))
        trainTab.tap()

        // Default lands on Calendar.
        XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 5))

        // Segment pills exist and Techniques is selectable.
        let techniquesPill = app.buttons["Techniques"]
        XCTAssertTrue(techniquesPill.waitForExistence(timeout: 3))
        techniquesPill.tap()
        XCTAssertTrue(app.navigationBars["Techniques"].waitForExistence(timeout: 5))

        // Back to Calendar.
        let calendarPill = app.buttons["Calendar"]
        XCTAssertTrue(calendarPill.exists)
        calendarPill.tap()
        XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 5))
    }

    // MARK: - Log Session (entry point from Home)

    func testLogSession_fromHomeOpensSessionEntry() throws {
        let app = launchSignedIn()

        // Home's primary CTA opens the session entry sheet.
        let logButton = app.buttons["Log a new training session"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        // Sheet opens
        XCTAssertTrue(app.navigationBars["Log Session"].waitForExistence(timeout: 5))

        // Cancel dismisses cleanly back to Home.
        app.buttons["Cancel"].tap()
        let greeting = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Good' OR label CONTAINS 'Ready'")
        )
        XCTAssertTrue(greeting.firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Log Session Form

    func testLogSessionForm_showsRequiredSections() throws {
        let app = launchSignedIn()

        let logButton = app.buttons["Log a new training session"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        XCTAssertTrue(app.navigationBars["Log Session"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Session Type"].exists)
        XCTAssertTrue(app.staticTexts["Focus Areas"].exists)

        let saveButton = app.descendants(matching: .any)["Save Session"]
        XCTAssertTrue(saveButton.exists)
    }
}
