import Combine
import Foundation

struct GitHubRelease: Decodable, Equatable {
    let tagName: String
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}

@MainActor
protocol ReleaseFetching: AnyObject {
    func latestRelease() async throws -> GitHubRelease
}

@MainActor
final class GitHubReleaseClient: ReleaseFetching {
    private let endpoint = URL(string: "https://api.github.com/repos/carlosfachini/coffeebar/releases/latest")!

    func latestRelease() async throws -> GitHubRelease {
        var request = URLRequest(url: endpoint)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("CoffeeBar Update Checker", forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadRevalidatingCacheData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse,
              (200 ... 299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(GitHubRelease.self, from: data)
    }
}

struct SemanticVersion: Comparable, Equatable {
    let components: [Int]

    init?(_ value: String) {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .drop(while: { $0 == "v" || $0 == "V" })
            .split(separator: "-", maxSplits: 1)[0]

        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
        guard !parts.isEmpty,
              parts.count <= 3,
              parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isNumber) }) else {
            return nil
        }

        let parsedComponents = parts.compactMap { Int($0) }
        components = parsedComponents + Array(
            repeating: 0,
            count: 3 - parsedComponents.count
        )
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let componentCount = max(lhs.components.count, rhs.components.count)

        for index in 0 ..< componentCount {
            let lhsValue = index < lhs.components.count ? lhs.components[index] : 0
            let rhsValue = index < rhs.components.count ? rhs.components[index] : 0

            if lhsValue != rhsValue {
                return lhsValue < rhsValue
            }
        }

        return false
    }
}

@MainActor
final class UpdateChecker: ObservableObject {
    @Published private(set) var latestVersion: String?
    @Published private(set) var releaseURL: URL?
    @Published private(set) var isUpdateAvailable = false

    private let currentVersion: String
    private let client: ReleaseFetching
    private let defaults: UserDefaults
    private let now: () -> Date
    private let cacheInterval: TimeInterval
    private let lastCheckKey = "updates.lastCheckDate"

    init(
        currentVersion: String = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "0.0.0",
        client: ReleaseFetching? = nil,
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = Date.init,
        cacheInterval: TimeInterval = 24 * 60 * 60
    ) {
        self.currentVersion = currentVersion
        self.client = client ?? GitHubReleaseClient()
        self.defaults = defaults
        self.now = now
        self.cacheInterval = cacheInterval
    }

    func checkIfNeeded(force: Bool = false) async {
        if !force,
           let lastCheck = defaults.object(forKey: lastCheckKey) as? Date,
           now().timeIntervalSince(lastCheck) < cacheInterval {
            return
        }

        defaults.set(now(), forKey: lastCheckKey)

        do {
            let release = try await client.latestRelease()
            let normalizedVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))

            guard let installed = SemanticVersion(currentVersion),
                  let latest = SemanticVersion(normalizedVersion) else {
                return
            }

            latestVersion = normalizedVersion
            releaseURL = release.htmlURL
            isUpdateAvailable = installed < latest
        } catch {
            // Update checks are best-effort and must never affect Keep Awake.
        }
    }
}
