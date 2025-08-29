//
//  EZProxyApp.swift
//  EZProxy Universal
//
//  Cross-platform SwiftUI app entry point
//

import SwiftUI

@main
struct EZProxyApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            SettingsView()
                .environmentObject(settingsViewModel)
                .frame(minWidth: 500, idealWidth: 600, maxWidth: 800,
                       minHeight: 600, idealHeight: 700, maxHeight: 900)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 700)
        #else
        WindowGroup {
            SettingsView()
                .environmentObject(settingsViewModel)
        }
        #endif
    }
}