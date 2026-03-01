import XCTest

// MARK: - Waza UI Tests
//
// Covers:
//   1. Onboarding — Welcome screen visible when signed out
//   2. Onboarding — "Get Started" and "Sign In" CTAs visible
//   3. Tab bar — Sessions, Progress, Profile tabs visible when signed in
//   4. Sessions tab — List renders (empty or populated)
//   5. Sessions tab — Log Session sheet opens via "+" button
//   6. Session Entry — Cancel dismisses the sheet
//   7. Progress tab — navigation title visible
//   8. Profile tab — navigation title visible

@MainActor
final class WazaUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    /// Launches the app in a signed-out mock state (shows onboarding).
    private func launchSignedOut() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        return app
    }

    /// Launches the app in a signed-in mock state (shows main tab bar with seed data).
    private func launchSignedIn() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        return app
    }

    /// Taps the "+" toolbar button on the Sessions screen to open the Log Session sheet.
    private func openLogSessionSheet(app: XCUIApplication) {
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
    }

    // MARK: - Onboarding

    func testWelcomeScreen_isShownWhenSignedOut() throws {
        let app = launchSignedOut()

        // "Waza" wordmark should be visible
        let title = app.staticTexts["Waza"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
    }

    func testWelcomeScreen_subtitleVisible() throws {
        let app = launchSignedOut()

        let subtitle = app.staticTexts["Your BJJ journey, tracked."]
        XCTAssertTrue(subtitle.waitForExistence(timeout: 5))
    }

    func testWelcomeScreen_getStartedButtonVisible() throws {
        let app = launchSignedOut()

        let startButton = app.buttons["StartButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
    }

    func testWelcomeScreen_signInLinkVisible() throws {
        let app = launchSignedOut()

        let signInButton = app.buttons["Already have an account? Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
    }

    // MARK: - Tab Bar (Signed In)

    func testTabBar_sessionsTabVisible() throws {
        let app = launchSignedIn()

        let sessionsTab = app.descendants(matching: .any)["Sessions"]
        XCTAssertTrue(sessionsTab.waitForExistence(timeout: 5))
    }

    func testTabBar_progressTabVisible() throws {
        let app = launchSignedIn()

        let progressTab = app.descendants(matching: .any)["Progress"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 5))
    }

    func testTabBar_profileTabVisible() throws {
        let app = launchSignedIn()

        let profileTab = app.descendants(matching: .any)["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
    }

    // MARK: - Sessions Screen

    func testSessionsScreen_navigationTitleVisible() throws {
        let app = launchSignedIn()

        let navTitle = app.navigationBars["Sessions"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testSessionsScreen_addButtonVisible() throws {
        let app = launchSignedIn()

        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
    }

    func testSessionsScreen_seedDataSessionsDisplayed() throws {
        let app = launchSignedIn()

        // The sessions list should not show the empty-state message since seed data is loaded
        let emptyLabel = app.staticTexts["No Sessions Yet"]
        // Give the list a moment to load then verify empty state is absent
        _ = app.navigationBars["Sessions"].waitForExistence(timeout: 5)
        XCTAssertFalse(emptyLabel.exists)
    }

    // MARK: - Log Session Sheet

    func testLogSession_sheetOpens() throws {
        let app = launchSignedIn()

        openLogSessionSheet(app: app)

        let sheetTitle = app.navigationBars["Log Session"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 5))
    }

    func testLogSession_cancelDismissesSheet() throws {
        let app = launchSignedIn()

        openLogSessionSheet(app: app)

        let sheetTitle = app.navigationBars["Log Session"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 5))

        app.buttons["Cancel"].tap()

        // Sheet should be gone and sessions list back in view
        let sessionNav = app.navigationBars["Sessions"]
        XCTAssertTrue(sessionNav.waitForExistence(timeout: 5))
    }

    func testLogSession_sessionTypeCardsVisible() throws {
        let app = launchSignedIn()

        openLogSessionSheet(app: app)

        let typeLabel = app.staticTexts["Session Type"]
        XCTAssertTrue(typeLabel.waitForExistence(timeout: 5))
    }

    func testLogSession_saveButtonVisible() throws {
        let app = launchSignedIn()

        openLogSessionSheet(app: app)

        // "Save Session" sits inside .anyButton(.press), so it appears as a button in the a11y tree
        let saveButton = app.descendants(matching: .any)["Save Session"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
    }

    // MARK: - Progress Tab

    func testProgressTab_navigationTitleVisible() throws {
        let app = launchSignedIn()

        let progressTab = app.descendants(matching: .any)["Progress"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 5))
        progressTab.tap()

        let navTitle = app.navigationBars["Progress"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testProgressTab_trainingGoalsSectionVisible() throws {
        let app = launchSignedIn()

        let progressTab = app.descendants(matching: .any)["Progress"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 5))
        progressTab.tap()

        let goalsHeader = app.staticTexts["Training Goals"]
        XCTAssertTrue(goalsHeader.waitForExistence(timeout: 5))
    }

    // MARK: - Profile Tab

    func testProfileTab_navigationTitleVisible() throws {
        let app = launchSignedIn()

        let profileTab = app.descendants(matching: .any)["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let navTitle = app.navigationBars["Profile"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testProfileTab_beltHistorySectionVisible() throws {
        let app = launchSignedIn()

        let profileTab = app.descendants(matching: .any)["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let beltSection = app.staticTexts["Belt History"]
        XCTAssertTrue(beltSection.waitForExistence(timeout: 5))
    }

    func testProfileTab_achievementsSectionVisible() throws {
        let app = launchSignedIn()

        let profileTab = app.descendants(matching: .any)["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let achievements = app.staticTexts["Achievements"]
        XCTAssertTrue(achievements.waitForExistence(timeout: 5))
    }
}
