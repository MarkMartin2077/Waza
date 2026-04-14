import XCTest

/// Drives the signed-in mock app through every key screen and writes PNG screenshots
/// to `/Users/Markyminaj/Desktop/WazaScreenshots/`.
///
/// Not part of the regular test suite — opt-in via `-only-testing`. Each step is best-effort:
/// if a screen can't be reached (UI changed, data missing), the test logs and moves on rather
/// than fail the whole run.
@MainActor
final class ScreenshotTests: XCTestCase {

    private let outputDirectory = URL(fileURLWithPath: "/Users/Markyminaj/Desktop/WazaScreenshots")

    override func setUpWithError() throws {
        continueAfterFailure = true
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Single Flow

    func testCaptureAllKeyScreens() throws {
        let app = XCUIApplication()
        // MARKETING_MODE seeds an impressive "active user" state for App Store shots —
        // level 12, 22-day streak, 30+ sessions, unlocked achievements, completed goals.
        // See MarketingDataSeeder.swift.
        app.launchArguments = ["UI_TESTING", "SIGNED_IN", "MARKETING_MODE"]
        app.launch()

        // Seeder runs async for XP/streak events — give it extra time to settle
        sleep(3)

        // Give the app a moment to settle on first frame
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 5)
        sleep(1)

        // Dismiss iOS location permission dialog if it appears
        dismissSystemAlerts()
        sleep(1)

        // 01 — Dashboard (Home tab default)
        capture(app, name: "01_dashboard")

        // Scroll the dashboard to show lower sections (This Week, Recent Sessions)
        app.swipeUp()
        sleep(1)
        capture(app, name: "02_dashboard_scrolled")
        app.swipeDown()
        sleep(1)

        // 03 — Sessions tab
        if tap(app, label: "Sessions") {
            _ = app.navigationBars["Sessions"].waitForExistence(timeout: 5)
            sleep(1)
            capture(app, name: "03_sessions")

            // 04 — Session Detail (tap first cell)
            let firstCell = app.cells.firstMatch
            if firstCell.waitForExistence(timeout: 3) {
                firstCell.tap()
                sleep(1)
                capture(app, name: "04_session_detail")
                // back
                app.navigationBars.buttons.firstMatch.tap()
                sleep(1)
            }

            // 05 — Log Session sheet
            if app.buttons["Log session"].waitForExistence(timeout: 3) {
                app.buttons["Log session"].tap()
                _ = app.navigationBars["Log Session"].waitForExistence(timeout: 5)
                sleep(1)
                capture(app, name: "05_log_session")
                app.buttons["Cancel"].tap()
                sleep(1)
            }
        }

        // 06 — Progress tab
        if tap(app, label: "Progress") {
            _ = app.navigationBars["Progress"].waitForExistence(timeout: 5)
            sleep(2) // charts may take a beat to render
            capture(app, name: "06_progress")
        }

        // 07 — Profile tab
        if tap(app, label: "Profile") {
            _ = app.navigationBars["Profile"].waitForExistence(timeout: 5)
            sleep(1)
            capture(app, name: "07_profile")

            // 08 — Achievements
            let achievementsRow = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Achievements'")).firstMatch
            if achievementsRow.waitForExistence(timeout: 3) {
                achievementsRow.tap()
                sleep(2)
                capture(app, name: "08_achievements")
                app.navigationBars.buttons.firstMatch.tap()
                sleep(1)
            }

            // 09 — Monthly Report
            let monthlyReportRow = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Monthly Report'")).firstMatch
            if monthlyReportRow.waitForExistence(timeout: 3) {
                monthlyReportRow.tap()
                sleep(3) // report builder takes a moment
                capture(app, name: "09_monthly_report")
                app.navigationBars.buttons.firstMatch.tap()
                sleep(1)
            }
        }

        // 10 — Technique Journal (via Dashboard card)
        if tap(app, label: "Home") {
            sleep(1)
            // Scroll to surface the technique journal card if needed
            let journalCard = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Technique Journal'")).firstMatch
            if !journalCard.waitForExistence(timeout: 2) {
                app.swipeUp()
                sleep(1)
            }
            if journalCard.waitForExistence(timeout: 3) {
                journalCard.tap()
                _ = app.navigationBars["Technique Journal"].waitForExistence(timeout: 5)
                sleep(1)
                capture(app, name: "10_technique_journal")
            }
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
