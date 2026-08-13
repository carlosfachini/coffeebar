import ServiceManagement
import XCTest
@testable import CoffeeBar

@MainActor
final class LaunchAtLoginManagerTests: XCTestCase {
    func testStartsDisabledWhenServiceIsNotRegistered() {
        let service = LoginItemServiceSpy(status: .notRegistered)
        let manager = LaunchAtLoginManager(service: service)

        XCTAssertFalse(manager.isEnabled)
        XCTAssertNil(manager.statusMessage)
    }

    func testEnablingRegistersService() {
        let service = LoginItemServiceSpy(status: .notRegistered)
        let manager = LaunchAtLoginManager(service: service)

        manager.setEnabled(true)

        XCTAssertTrue(manager.isEnabled)
        XCTAssertEqual(service.registerCallCount, 1)
    }

    func testDisablingUnregistersService() {
        let service = LoginItemServiceSpy(status: .enabled)
        let manager = LaunchAtLoginManager(service: service)

        manager.setEnabled(false)

        XCTAssertFalse(manager.isEnabled)
        XCTAssertEqual(service.unregisterCallCount, 1)
    }

    func testRegistrationFailureKeepsActualStateAndShowsMessage() {
        let service = LoginItemServiceSpy(status: .notRegistered, shouldFail: true)
        let manager = LaunchAtLoginManager(service: service)

        manager.setEnabled(true)

        XCTAssertFalse(manager.isEnabled)
        XCTAssertEqual(manager.statusMessage, "Could not change Launch at Login")
    }
}

@MainActor
private final class LoginItemServiceSpy: LoginItemServicing {
    var status: SMAppService.Status
    let shouldFail: Bool

    private(set) var registerCallCount = 0
    private(set) var unregisterCallCount = 0

    init(status: SMAppService.Status, shouldFail: Bool = false) {
        self.status = status
        self.shouldFail = shouldFail
    }

    func register() throws {
        registerCallCount += 1
        if shouldFail {
            throw TestError.expected
        }
        status = .enabled
    }

    func unregister() throws {
        unregisterCallCount += 1
        if shouldFail {
            throw TestError.expected
        }
        status = .notRegistered
    }

    private enum TestError: Error {
        case expected
    }
}

