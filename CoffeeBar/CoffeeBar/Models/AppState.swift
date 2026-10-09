//
//  AppState.swift
//  CoffeeBar
//
//  Created by Carlos Fachini on 13/08/26.
//

import Combine
import Foundation

enum AutoOffDuration: CaseIterable, Equatable, Identifiable {
    case thirtyMinutes
    case oneHour
    case untilTurnedOff

    var id: Self { self }

    var label: String {
        switch self {
        case .thirtyMinutes:
            "30 minutes"
        case .oneHour:
            "1 hour"
        case .untilTurnedOff:
            "Until turned off"
        }
    }

    fileprivate var timeInterval: TimeInterval? {
        switch self {
        case .thirtyMinutes:
            30 * 60
        case .oneHour:
            60 * 60
        case .untilTurnedOff:
            nil
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var autoOffDuration: AutoOffDuration = .thirtyMinutes
    @Published private(set) var autoOffDate: Date?

    var statusMessage: String {
        isActive
            ? "Active — idle sleep is blocked"
            : "Inactive — normal sleep is allowed"
    }

    private let sleepManager: SleepManaging
    private var autoOffTask: Task<Void, Never>?
    private var autoOffID: UUID?

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

        if shouldBeActive {
            isActive = sleepManager.activate()
            if isActive {
                scheduleAutoOff()
            }
        } else {
            deactivate()
        }
    }

    func deactivate() {
        cancelAutoOff()
        sleepManager.deactivate()
        isActive = false
    }

    func setAutoOffDuration(_ duration: AutoOffDuration) {
        guard duration != autoOffDuration else {
            return
        }

        autoOffDuration = duration
        if isActive {
            scheduleAutoOff()
        }
    }

    private func scheduleAutoOff() {
        cancelAutoOff()

        guard let timeInterval = autoOffDuration.timeInterval else {
            return
        }

        let id = UUID()
        autoOffID = id
        autoOffDate = Date().addingTimeInterval(timeInterval)
        autoOffTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
            } catch {
                return
            }

            guard let self, self.autoOffID == id else {
                return
            }

            self.deactivate()
        }
    }

    private func cancelAutoOff() {
        autoOffTask?.cancel()
        autoOffTask = nil
        autoOffID = nil
        autoOffDate = nil
    }
}
