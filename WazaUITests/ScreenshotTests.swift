import XCTest

/// Drives the signed-in mock app through every key screen and writes PNG screenshots
/// to `/Users/Markyminaj/Desktop/PersonalApps/Waza/Screenshots/`.
///
/// Not part of the regular test suite — opt-in via `-only-testing`. Each step is best-effort:
/// if a screen can't be reached (UI changed, data missing), the test logs and moves on rather
/// than fail the whole run.
@MainActor
final class ScreenshotTests: XCTestCase {

    private let outputDirectory = URL(fileURLWithPath: "/Users/Markyminaj/Desktop/PersonalApps/Waza/Screenshots")

    override func setUpWithError() throws {
        continueAfterFailure = true
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Single Flow

    func testCaptureAllKeyScreens() throws {
        let app = launchApp()
        captureHome(app)
        captureTrainTab(app)
        captureProgressTab(app)
        captureProfileTab(app)
    }

    // MARK: - Steps

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        // Launch flag seeds an impressive "active user" state — level 12, 22-day streak,
        // 30+ sessions, unlocked achievements, completed goals. See MarketingDataSeeder.swift.
        app.launchArguments = ["UI_TESTING", "SIGNED_IN", "MARKETING_MODE"]
        app.launch()

        // Seeder runs async for XP/streak events — give it extra time to settle.
        sleep(3)
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 5)
        sleep(1)

        dismissSystemAlerts()
        sleep(1)

        return app
    }

    private func captureHome(_ app: XCUIApplication) {
        guard tap(app, label: "Home") else { return }
        sleep(1)
        capture(app, name: "01_home")

        // Scroll to show lower sections (challenges, upcoming class).
        app.swipeUp()
        sleep(1)
        capture(app, name: "02_home_scrolled")
        app.swipeDown()
        sleep(1)
    }

    private func captureTrainTab(_ app: XCUIApplication) {
        guard tap(app, label: "Train") else { return }
        sleep(1)

        // Default segment is Calendar.
        capture(app, name: "03_train_calendar")

        // Day detail — tap a today-ish cell if present (seeder data may not populate mid-month).
        // Best-effort; calendar cells aren't individually accessible without identifiers.
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 3) {
            firstCell.tap()
            sleep(1)
            capture(app, name: "04_day_detail_or_session")
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }

        // Switch to Techniques segment.
        if app.buttons["Techniques"].waitForExistence(timeout: 3) {
            app.buttons["Techniques"].tap()
            sleep(1)
            capture(app, name: "05_train_techniques")
        }

        // Back to Calendar to finish the sweep.
        if app.buttons["Calendar"].waitForExistence(timeout: 3) {
            app.buttons["Calendar"].tap()
            sleep(1)
            capture(app, name: "06_train_calendar_again")
        }
    }

    private func captureProgressTab(_ app: XCUIApplication) {
        guard tap(app, label: "Progress") else { return }
        _ = app.navigationBars["Progress"].waitForExistence(timeout: 5)
        sleep(2) // charts may take a beat to render
        capture(app, name: "07_progress")

        // Scroll to reveal achievements / monthly report / belt cards.
        app.swipeUp()
        sleep(1)
        capture(app, name: "08_progress_scrolled")

        // Achievements
        let achievementsRow = app.buttons
            .containing(NSPredicate(format: "label CONTAINS 'Achievements'")).firstMatch
        if achievementsRow.waitForExistence(timeout: 3) {
            achievementsRow.tap()
            sleep(2)
            capture(app, name: "09_achievements")
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }

        // Monthly Report
        let monthlyReportRow = app.buttons
            .containing(NSPredicate(format: "label CONTAINS 'Monthly Report'")).firstMatch
        if monthlyReportRow.waitForExistence(timeout: 3) {
            monthlyReportRow.tap()
            sleep(3) // report builder takes a moment
            capture(app, name: "10_monthly_report")
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
    }

    private func captureProfileTab(_ app: XCUIApplication) {
        guard tap(app, label: "Profile") else { return }
        _ = app.navigationBars["Profile"].waitForExistence(timeout: 5)
        sleep(1)
        capture(app, name: "11_profile")

        // Settings
        let settingsButton = app.buttons
            .containing(NSPredicate(format: "label CONTAINS[c] 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            sleep(2)
            capture(app, name: "12_settings")
        }
    }

    // MARK: - Helpers

    private func capture(_ app: XCUIApplication, name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let data = screenshot.pngRepresentation
        let url = outputDirectory.appendingPathComponent("\(name).png")
        do {
            try data.write(to: url)
            print("[Screenshot] wrote \(url.path)")
        } catch {
            XCTFail("Failed to write screenshot \(name): \(error)")
        }

        // Also attach to xcresult for reference
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Dismisses any system-level permission alerts (location, notifications) by tapping
    /// the preferred "Allow While Using App" button, falling back to common alternatives.
    private func dismissSystemAlerts() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let candidates = ["Allow While Using App", "Allow Once", "Allow", "OK"]
        for label in candidates {
            let button = springboard.buttons[label]
            if button.waitForExistence(timeout: 2) {
                button.tap()
                return
            }
        }
    }

    /// Tap a tab bar item by its label. Returns true if found.
    @discardableResult
    private func tap(_ app: XCUIApplication, label: String) -> Bool {
        // Try tab bar buttons first
        let tabButton = app.tabBars.buttons[label]
        if tabButton.waitForExistence(timeout: 3) {
            tabButton.tap()
            return true
        }
        // Fallback to any descendant with the label
        let fallback = app.descendants(matching: .any)[label]
        if fallback.waitForExistence(timeout: 2) {
            fallback.tap()
            return true
        }
        return false
    }
}
