//
//  SleepManager.swift
//  CoffeeBar
//
//  Created by Carlos Fachini on 13/08/26.
//

import Foundation
import OSLog

@MainActor
protocol SleepManaging: AnyObject {
    @discardableResult
    func activate() -> Bool

    func deactivate()
}

@MainActor
final class SleepManager: SleepManaging {
    private var activity: NSObjectProtocol?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CoffeeBar",
        category: "SleepManager"
    )

    @discardableResult
    func activate() -> Bool {
        guard activity == nil else {
            return true
        }

        activity = ProcessInfo.processInfo.beginActivity(
            options: .idleSystemSleepDisabled,
            reason: "CoffeeBar is keeping the Mac awake"
        )

        let isActive = activity != nil
        logger.info("Keep Awake activated: \(isActive, privacy: .public)")
        return isActive
    }

    func deactivate() {
        guard let activity else {
            return
        }

        ProcessInfo.processInfo.endActivity(activity)
        self.activity = nil
        logger.info("Keep Awake deactivated")
    }

    deinit {
        guard let activity else {
            return
        }

        ProcessInfo.processInfo.endActivity(activity)
    }
}
