import Testing
import Foundation
@testable import Waza

// MARK: - Test Mocks

@MainActor
final class StubWelcomeBackInteractor: WelcomeBackInteractor {
    var stubbedUserName: String = "Mark"
    var capturedEventNames: [String] = []
    var capturedEventParameters: [[String: Any]?] = []
    var capturedHaptics: [HapticOption] = []

    var currentUserName: String { stubbedUserName }

    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {}

    func trackEvent(event: AnyLoggableEvent) {
        capturedEventNames.append(event.eventName)
        capturedEventParameters.append(event.parameters)
    }

    func trackEvent(event: LoggableEvent) {
        capturedEventNames.append(event.eventName)
        capturedEventParameters.append(event.parameters)
    }

    func trackScreenEvent(event: LoggableEvent) {
        capturedEventNames.append(event.eventName)
        capturedEventParameters.append(event.parameters)
    }

    func playHaptic(option: HapticOption) {
        capturedHaptics.append(option)
    }

    func eventCount(named name: String) -> Int {
        capturedEventNames.filter { $0 == name }.count
    }

    func lastParameters(for name: String) -> [String: Any]? {
        guard let idx = capturedEventNames.lastIndex(of: name) else { return nil }
        return capturedEventParameters[idx]
    }
}

@MainActor
final class StubWelcomeBackRouter: WelcomeBackRouter {
    var router: AnyRouter { fatalError("Router not used in unit tests") }
    var dismissCount: Int = 0

    func dismissScreen() {
        dismissCount += 1
    }
}

// MARK: - Helpers

@MainActor
struct WelcomeBackTestHarness {
    let presenter: WelcomeBackPresenter
    let interactor: StubWelcomeBackInteractor
    let router: StubWelcomeBackRouter
}

@MainActor
func makeWelcomeBackPresenter() -> WelcomeBackTestHarness {
    let interactor = StubWelcomeBackInteractor()
    let router = StubWelcomeBackRouter()
    let presenter = WelcomeBackPresenter(interactor: interactor, router: router)
    return WelcomeBackTestHarness(presenter: presenter, interactor: interactor, router: router)
}

// MARK: - Analytics Tests

@Suite("WelcomeBackPresenter - Analytics") @MainActor
struct WelcomeBackAnalyticsTests {

    @Test("onAppear tracks screen event with is_new_user parameter")
    func onAppearTracksScreenEvent() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let interactor = harness.interactor
        let delegate = WelcomeBackDelegate(isNewUser: true, onComplete: nil)

        // WHEN
        presenter.onViewAppear(delegate: delegate)

        // THEN
        #expect(interactor.eventCount(named: "WelcomeBackView_Appear") == 1)
        let params = interactor.lastParameters(for: "WelcomeBackView_Appear")
        #expect(params?["is_new_user"] as? Bool == true)
    }

    @Test("Tap fires TapSkip then Complete with manual trigger")
    func tapFiresSkipAndComplete() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let interactor = harness.interactor
        let delegate = WelcomeBackDelegate(isNewUser: false, onComplete: nil)

        // WHEN
        presenter.onViewTapped(delegate: delegate)

        // THEN
        #expect(interactor.eventCount(named: "WelcomeBackView_TapSkip") == 1)
        #expect(interactor.eventCount(named: "WelcomeBackView_Complete") == 1)

        let completeParams = interactor.lastParameters(for: "WelcomeBackView_Complete")
        #expect(completeParams?["trigger"] as? String == "manual")
        #expect(completeParams?["is_new_user"] as? Bool == false)
    }

    @Test("Auto-complete fires Complete with auto trigger")
    func autoCompleteFiresCorrectTrigger() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let interactor = harness.interactor
        let delegate = WelcomeBackDelegate(isNewUser: true, onComplete: nil)

        // WHEN — simulate the timer firing
        presenter.completeIfNeeded(delegate: delegate, trigger: .auto)

        // THEN
        #expect(interactor.eventCount(named: "WelcomeBackView_Complete") == 1)
        #expect(interactor.eventCount(named: "WelcomeBackView_TapSkip") == 0)

        let params = interactor.lastParameters(for: "WelcomeBackView_Complete")
        #expect(params?["trigger"] as? String == "auto")
    }

    @Test("Second completion attempt is ignored (no duplicate events)")
    func doubleCompleteDoesNotDoubleFire() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let interactor = harness.interactor
        let delegate = WelcomeBackDelegate(isNewUser: false, onComplete: nil)

        // WHEN — user taps then timer also fires
        presenter.onViewTapped(delegate: delegate)
        presenter.completeIfNeeded(delegate: delegate, trigger: .auto)

        // THEN — only the first (manual) completion is recorded
        #expect(interactor.eventCount(named: "WelcomeBackView_Complete") == 1)
        let params = interactor.lastParameters(for: "WelcomeBackView_Complete")
        #expect(params?["trigger"] as? String == "manual")
    }

    @Test("Tap after completion does not fire TapSkip again")
    func tapAfterCompleteIsIgnored() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let interactor = harness.interactor
        let delegate = WelcomeBackDelegate(isNewUser: false, onComplete: nil)

        // WHEN
        presenter.completeIfNeeded(delegate: delegate, trigger: .auto)
        presenter.onViewTapped(delegate: delegate)

        // THEN
        #expect(interactor.eventCount(named: "WelcomeBackView_TapSkip") == 0)
        #expect(interactor.eventCount(named: "WelcomeBackView_Complete") == 1)
    }
}

// MARK: - Behavior Tests

@Suite("WelcomeBackPresenter - Behavior") @MainActor
struct WelcomeBackBehaviorTests {

    @Test("Completion dismisses the screen exactly once")
    func completeDismissesRouter() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let router = harness.router
        let delegate = WelcomeBackDelegate(isNewUser: false, onComplete: nil)

        // WHEN
        presenter.completeIfNeeded(delegate: delegate, trigger: .manual)
        presenter.completeIfNeeded(delegate: delegate, trigger: .auto)

        // THEN — only one dismiss despite two calls
        #expect(router.dismissCount == 1)
    }

    @Test("onComplete callback fires exactly once")
    func callbackFiresOnce() {
        // GIVEN
        let presenter = makeWelcomeBackPresenter().presenter
        var callbackCount = 0
        let delegate = WelcomeBackDelegate(
            isNewUser: false,
            onComplete: { callbackCount += 1 }
        )

        // WHEN
        presenter.completeIfNeeded(delegate: delegate, trigger: .manual)
        presenter.completeIfNeeded(delegate: delegate, trigger: .auto)
        presenter.onViewTapped(delegate: delegate)

        // THEN
        #expect(callbackCount == 1)
    }

    @Test("name property returns interactor's currentUserName")
    func nameReflectsInteractor() {
        // GIVEN
        let harness = makeWelcomeBackPresenter()
        let presenter = harness.presenter
        let interactor = harness.interactor
        interactor.stubbedUserName = "Saulo"

        // THEN
        #expect(presenter.name == "Saulo")
    }

    @Test("hasCompleted flag is set on first completion")
    func hasCompletedFlag() {
        // GIVEN
        let presenter = makeWelcomeBackPresenter().presenter
        let delegate = WelcomeBackDelegate(isNewUser: false, onComplete: nil)
        #expect(presenter.hasCompleted == false)

        // WHEN
        presenter.completeIfNeeded(delegate: delegate, trigger: .auto)

        // THEN
        #expect(presenter.hasCompleted == true)
    }
}

// MARK: - Delegate Tests

@Suite("WelcomeBackDelegate") @MainActor
struct WelcomeBackDelegateTests {

    @Test("New user delegate uses 始 (begin) kanji")
    func newUserKanji() {
        let delegate = WelcomeBackDelegate(isNewUser: true, onComplete: nil)
        #expect(delegate.kanji == "始")
    }

    @Test("Returning user delegate uses 還 (return) kanji")
    func returningUserKanji() {
        let delegate = WelcomeBackDelegate(isNewUser: false, onComplete: nil)
        #expect(delegate.kanji == "還")
    }

    @Test("Delegate event parameters include is_new_user")
    func eventParametersIncludeIsNewUser() {
        let newUser = WelcomeBackDelegate(isNewUser: true, onComplete: nil)
        let returning = WelcomeBackDelegate(isNewUser: false, onComplete: nil)

        #expect(newUser.eventParameters?["is_new_user"] as? Bool == true)
        #expect(returning.eventParameters?["is_new_user"] as? Bool == false)
    }
}
