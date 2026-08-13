//
//  AppState.swift
//  CoffeeBar
//
//  Created by Carlos Fachini on 13/08/26.
//

import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var isActive = false

    var statusMessage: String {
        isActive
            ? "Active — idle sleep is blocked"
            : "Inactive — normal sleep is allowed"
    }

    private let sleepManager: SleepManaging

    init() {
        sleepManager = SleepManager()
    }

    init(sleepManager: SleepManaging) {
        self.sleepManager = sleepManager
    }

    func setActive(_ shouldBeActive: Bool) {
        guard shouldBeActive != isActive else {
            return
        }

        let activationSucceeded: Bool

        if shouldBeActive {
            activationSucceeded = sleepManager.activate()
        } else {
            sleepManager.deactivate()
            activationSucceeded = false
        }

        isActive = activationSucceeded
    }

    func deactivate() {
        sleepManager.deactivate()
        isActive = false
    }
}
