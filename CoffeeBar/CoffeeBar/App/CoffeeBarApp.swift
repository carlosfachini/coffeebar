//
//  CoffeeBarApp.swift
//  CoffeeBar
//
//  Created by Carlos Fachini on 13/08/26.
//

import AppKit
import SwiftUI

@main
struct CoffeeBarApp: App {
    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) private var applicationDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                appState: applicationDelegate.appState,
                launchAtLoginManager: applicationDelegate.launchAtLoginManager,
                updateChecker: applicationDelegate.updateChecker,
                quit: quit
            )
        } label: {
            MenuBarStatusIcon(appState: applicationDelegate.appState)
        }
        .menuBarExtraStyle(.window)
    }

    private func quit() {
        applicationDelegate.appState.deactivate()
        NSApplication.shared.terminate(nil)
    }
}

private struct MenuBarStatusIcon: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: appState.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")

            if appState.isActive {
                Circle()
                    .fill(.primary)
                    .frame(width: 5, height: 5)
                    .offset(x: 2, y: -1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(appState.isActive ? "CoffeeBar active" : "CoffeeBar inactive")
        .accessibilityValue(appState.isActive ? "Keep Awake on" : "Keep Awake off")
    }
}

@MainActor
final class ApplicationDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    let launchAtLoginManager = LaunchAtLoginManager()
    let updateChecker = UpdateChecker()

    func applicationWillTerminate(_ notification: Notification) {
        appState.deactivate()
    }
}
