import XCTest

final class WazaUITestsLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Launch Screenshots

    /// Captures a screenshot of the onboarding (signed-out) launch state.
    @MainActor
    func testLaunchSignedOut() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch - Signed Out"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Captures a screenshot of the main app (signed-in) launch state.
    @MainActor
    func testLaunchSignedIn() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()

        // Wait for the tab bar to settle before capturing
        _ = app.descendants(matching: .any)["Sessions"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch - Signed In"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
