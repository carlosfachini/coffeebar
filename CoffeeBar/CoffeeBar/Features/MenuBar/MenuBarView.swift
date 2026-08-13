//
//  MenuBarView.swift
//  CoffeeBar
//
//  Created by Carlos Fachini on 13/08/26.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager
    @ObservedObject var updateChecker: UpdateChecker

    let quit: () -> Void

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("CoffeeBar", systemImage: "cup.and.saucer.fill")
                    .font(.headline)

                Spacer()

                Text("Version \(version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)

            Divider()

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep Mac Awake")
                        .fontWeight(.medium)

                    Text("Prevent idle system sleep")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(appState.isActive ? "On" : "Off")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle(
                    "Keep Mac Awake",
                    isOn: Binding(
                        get: { appState.isActive },
                        set: appState.setActive
                    )
                )
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(14)

            Label(
                appState.statusMessage,
                systemImage: appState.isActive ? "checkmark.circle.fill" : "moon.zzz"
            )
            .font(.caption)
            .foregroundStyle(appState.isActive ? Color.green : Color.secondary)
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .accessibilityLabel("CoffeeBar status: \(appState.statusMessage)")

            Divider()

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at Login")
                        .fontWeight(.medium)

                    Text("Start CoffeeBar when you sign in")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle(
                    "Launch at Login",
                    isOn: Binding(
                        get: { launchAtLoginManager.isEnabled },
                        set: launchAtLoginManager.setEnabled
                    )
                )
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(14)

            if let statusMessage = launchAtLoginManager.statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }

            if updateChecker.isUpdateAvailable,
               let latestVersion = updateChecker.latestVersion,
               let releaseURL = updateChecker.releaseURL {
                Divider()

                HStack(spacing: 10) {
                    Label("CoffeeBar \(latestVersion) is available", systemImage: "arrow.down.circle.fill")
                        .font(.caption)

                    Spacer()

                    Link("View Release", destination: releaseURL)
                        .font(.caption)
                }
                .padding(14)
            }

            Divider()

            HStack {
                Link("GitHub", destination: URL(string: "https://github.com/carlosfachini/coffeebar")!)
                    .buttonStyle(.plain)

                Spacer()

                Button("Quit CoffeeBar", action: quit)
                    .buttonStyle(.plain)
                    .keyboardShortcut("q")
            }
            .padding(14)
        }
        .frame(width: 300)
        .onAppear(perform: launchAtLoginManager.refresh)
        .task {
            await updateChecker.checkIfNeeded()
        }
    }
}
