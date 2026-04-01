import XCTest

// MARK: - Waza UI Tests
//
// Covers:
//   1. Onboarding — Welcome screen visible when signed out
//   2. Onboarding — "Get Started" and "Sign In" CTAs visible
//   3. Tab bar — Home, Sessions, Progress, Profile tabs visible when signed in
//   4. Home tab — Greeting and Log Session button visible
//   5. Sessions tab — List renders (empty or populated)
//   6. Sessions tab — Log Session sheet opens via "+" button
//   7. Session Entry — Cancel dismisses the sheet
//   8. Progress tab — navigation title visible
//   9. Profile tab — navigation title visible

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

    /// Navigates to the Sessions tab from wherever the app is.
    private func navigateToSessionsTab(app: XCUIApplication) {
        let sessionsTab = app.descendants(matching: .any)["Sessions"]
        XCTAssertTrue(sessionsTab.waitForExistence(timeout: 5))
        sessionsTab.tap()
    }

    /// Navigates to Sessions tab and taps the "+" button to open the Log Session sheet.
    private func openLogSessionSheet(app: XCUIApplication) {
        navigateToSessionsTab(app: app)
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
    }

    // MARK: - Onboarding

    func testWelcomeScreen_isShownWhenSignedOut() throws {
        let app = launchSignedOut()
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

    func testTabBar_homeTabVisible() throws {
        let app = launchSignedIn()
        let homeTab = app.descendants(matching: .any)["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
    }

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

    // MARK: - Home Screen

    func testHomeScreen_greetingVisible() throws {
        let app = launchSignedIn()
        // The greeting should contain "Good" (morning/afternoon/evening) or "Ready"
        let greeting = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good' OR label CONTAINS 'Ready'"))
        XCTAssertTrue(greeting.firstMatch.waitForExistence(timeout: 5))
    }

    func testHomeScreen_logSessionButtonVisible() throws {
        let app = launchSignedIn()
        let logButton = app.descendants(matching: .any)["Log Session"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
    }

    func testHomeScreen_thisWeekSectionVisible() throws {
        let app = launchSignedIn()
        let thisWeek = app.staticTexts["This Week"]
        XCTAssertTrue(thisWeek.waitForExistence(timeout: 5))
    }

    // MARK: - Sessions Screen

    func testSessionsScreen_navigationTitleVisible() throws {
        let app = launchSignedIn()
        navigateToSessionsTab(app: app)

        let navTitle = app.navigationBars["Sessions"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testSessionsScreen_addButtonVisible() throws {
        let app = launchSignedIn()
        navigateToSessionsTab(app: app)

        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
    }

    func testSessionsScreen_seedDataSessionsDisplayed() throws {
        let app = launchSignedIn()
        navigateToSessionsTab(app: app)

        let emptyLabel = app.staticTexts["No Sessions Yet"]
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

        let saveButton = app.descendants(matching: .any)["Save Session"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
    }

    func testLogSession_focusAreasSectionVisible() throws {
        let app = launchSignedIn()
        openLogSessionSheet(app: app)

        let focusLabel = app.staticTexts["Focus Areas"]
        XCTAssertTrue(focusLabel.waitForExistence(timeout: 5))
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

    // MARK: - Profile Tab

    func testProfileTab_navigationTitleVisible() throws {
        let app = launchSignedIn()

        let profileTab = app.descendants(matching: .any)["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let navTitle = app.navigationBars["Profile"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testProfileTab_trainingScheduleSectionVisible() throws {
        let app = launchSignedIn()

        let profileTab = app.descendants(matching: .any)["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let scheduleSection = app.staticTexts["Training Schedule"]
        XCTAssertTrue(scheduleSection.waitForExistence(timeout: 5))
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
