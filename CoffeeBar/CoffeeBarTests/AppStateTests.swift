import XCTest
@testable import CoffeeBar

@MainActor
final class AppStateTests: XCTestCase {
    func testStartsInactive() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        XCTAssertFalse(appState.isActive)
        XCTAssertEqual(appState.statusMessage, "Inactive — normal sleep is allowed")
        XCTAssertEqual(sleepManager.activateCallCount, 0)
        XCTAssertEqual(sleepManager.deactivateCallCount, 0)
    }

    func testActivationUpdatesStateAndStatus() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        appState.setActive(true)

        XCTAssertTrue(appState.isActive)
        XCTAssertEqual(appState.statusMessage, "Active — idle sleep is blocked")
        XCTAssertEqual(sleepManager.activateCallCount, 1)
    }

    func testDeactivationUpdatesStateAndStatus() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        appState.setActive(true)
        appState.setActive(false)

        XCTAssertFalse(appState.isActive)
        XCTAssertEqual(appState.statusMessage, "Inactive — normal sleep is allowed")
        XCTAssertEqual(sleepManager.deactivateCallCount, 1)
    }

    func testRepeatedStateRequestsDoNotCallSleepManagerAgain() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        appState.setActive(true)
        appState.setActive(true)
        appState.setActive(false)
        appState.setActive(false)

        XCTAssertEqual(sleepManager.activateCallCount, 1)
        XCTAssertEqual(sleepManager.deactivateCallCount, 1)
    }

    func testFailedActivationRemainsInactive() {
        let sleepManager = SleepManagerSpy(activationResult: false)
        let appState = AppState(sleepManager: sleepManager)

        appState.setActive(true)

        XCTAssertFalse(appState.isActive)
        XCTAssertEqual(appState.statusMessage, "Inactive — normal sleep is allowed")
        XCTAssertEqual(sleepManager.activateCallCount, 1)
    }

    func testAutoOffIsScheduledForActiveSession() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        appState.setActive(true)

        XCTAssertNotNil(appState.autoOffDate)
        XCTAssertEqual(appState.autoOffDuration, .thirtyMinutes)
    }

    func testTurningOffCancelsAutoOff() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        appState.setActive(true)
        appState.setActive(false)

        XCTAssertNil(appState.autoOffDate)
    }

    func testUntilTurnedOffDoesNotScheduleAutoOff() {
        let sleepManager = SleepManagerSpy()
        let appState = AppState(sleepManager: sleepManager)

        appState.setAutoOffDuration(.untilTurnedOff)
        appState.setActive(true)

        XCTAssertTrue(appState.isActive)
        XCTAssertNil(appState.autoOffDate)
    }
}

@MainActor
private final class SleepManagerSpy: SleepManaging {
    private let activationResult: Bool

    private(set) var activateCallCount = 0
    private(set) var deactivateCallCount = 0

    init(activationResult: Bool = true) {
        self.activationResult = activationResult
    }

    func activate() -> Bool {
        activateCallCount += 1
        return activationResult
    }

    func deactivate() {
        deactivateCallCount += 1
    }
}
