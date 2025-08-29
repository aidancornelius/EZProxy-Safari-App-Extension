//
//  EZProxyApp.swift
//  EZProxy
//
//  SwiftUI app entry point
//

import SwiftUI

@main
struct EZProxyApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 750)
    }
}