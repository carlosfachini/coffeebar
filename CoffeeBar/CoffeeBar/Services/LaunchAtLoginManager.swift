import Combine
import ServiceManagement

@MainActor
protocol LoginItemServicing: AnyObject {
    var status: SMAppService.Status { get }

    func register() throws
    func unregister() throws
}

extension SMAppService: LoginItemServicing {}

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var statusMessage: String?

    private let service: LoginItemServicing

    init(service: LoginItemServicing = SMAppService.mainApp) {
        self.service = service
        refresh()
    }

    func refresh() {
        isEnabled = service.status == .enabled

        if service.status == .requiresApproval {
            statusMessage = "Approval required in System Settings"
        } else if statusMessage == "Approval required in System Settings" {
            statusMessage = nil
        }
    }

    func setEnabled(_ shouldBeEnabled: Bool) {
        guard shouldBeEnabled != isEnabled else {
            return
        }

        do {
            if shouldBeEnabled {
                try service.register()
            } else {
                try service.unregister()
            }

            statusMessage = nil
        } catch {
            statusMessage = "Could not change Launch at Login"
        }

        refresh()
    }
}

