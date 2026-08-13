import XCTest
@testable import CoffeeBar

@MainActor
final class UpdateCheckerTests: XCTestCase {
    func testSemanticVersionComparison() {
        XCTAssertLessThan(SemanticVersion("0.1.0")!, SemanticVersion("0.2.0")!)
        XCTAssertEqual(SemanticVersion("v1.2")!, SemanticVersion("1.2.0")!)
        XCTAssertNil(SemanticVersion("latest"))
    }

    func testNewerReleaseBecomesAvailable() async {
        let release = GitHubRelease(
            tagName: "v0.2.0",
            htmlURL: URL(string: "https://github.com/carlosfachini/coffeebar/releases/tag/v0.2.0")!
        )
        let client = ReleaseClientSpy(release: release)
        let defaults = makeDefaults()
        let checker = UpdateChecker(
            currentVersion: "0.1.0",
            client: client,
            defaults: defaults,
            now: { Date(timeIntervalSince1970: 100) }
        )

        await checker.checkIfNeeded()

        XCTAssertTrue(checker.isUpdateAvailable)
        XCTAssertEqual(checker.latestVersion, "0.2.0")
        XCTAssertEqual(checker.releaseURL, release.htmlURL)
        XCTAssertEqual(client.callCount, 1)
    }

    func testCurrentReleaseDoesNotBecomeAvailable() async {
        let client = ReleaseClientSpy(
            release: GitHubRelease(
                tagName: "v0.1.0",
                htmlURL: URL(string: "https://github.com/carlosfachini/coffeebar/releases/tag/v0.1.0")!
            )
        )
        let checker = UpdateChecker(
            currentVersion: "0.1.0",
            client: client,
            defaults: makeDefaults()
        )

        await checker.checkIfNeeded()

        XCTAssertFalse(checker.isUpdateAvailable)
    }

    func testDailyCacheSkipsRepeatedRequest() async {
        let date = Date(timeIntervalSince1970: 1_000)
        let client = ReleaseClientSpy(
            release: GitHubRelease(
                tagName: "v0.2.0",
                htmlURL: URL(string: "https://github.com/carlosfachini/coffeebar/releases/latest")!
            )
        )
        let defaults = makeDefaults()
        defaults.set(date, forKey: "updates.lastCheckDate")
        let checker = UpdateChecker(
            currentVersion: "0.1.0",
            client: client,
            defaults: defaults,
            now: { date.addingTimeInterval(60) }
        )

        await checker.checkIfNeeded()

        XCTAssertEqual(client.callCount, 0)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "CoffeeBarTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}

@MainActor
private final class ReleaseClientSpy: ReleaseFetching {
    let release: GitHubRelease
    private(set) var callCount = 0

    init(release: GitHubRelease) {
        self.release = release
    }

    func latestRelease() async throws -> GitHubRelease {
        callCount += 1
        return release
    }
}

