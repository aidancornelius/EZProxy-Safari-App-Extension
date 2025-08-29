//
//  SettingsViewModel.swift
//  EZProxy Universal
//
//  Cross-platform settings management
//

import Foundation
import SwiftUI
import SafariServices

#if os(macOS)
import AppKit
#else
import UIKit
#endif

class SettingsViewModel: ObservableObject {
    @Published var proxyBase: String = ""
    @Published var useSSL: Bool = false
    @Published var keepTab: Bool = true
    @Published var useOpenAthens: Bool = false
    @Published var useContentScript: Bool = false
    @Published var settingsMessage: String = ""
    @Published var showSettingsMessage: Bool = false
    
    private let containerURL: URL? = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell"
    )
    
    private var plistURL: URL? {
        containerURL?.appendingPathComponent("HK6R36PLNR.com.cornelius-bell.EZProxySettings.plist")
    }
    
    init() {
        createPlistIfNeeded()
        loadSettings()
        setupSettingsObserver()
    }
    
    private func createPlistIfNeeded() {
        guard let url = plistURL,
              !FileManager.default.fileExists(atPath: url.path) else { return }
        
        let defaultSettings: [String: Any] = [
            "proxyBase": "proxy.slsa.sa.gov.au",
            "keepTab": true,
            "useSSL": false,
            "useOpenAthens": false,
            "useContentScript": false
        ]
        
        // Create backup directory
        if let backupDir = containerURL?.appendingPathComponent("Backups") {
            try? FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
        }
        
        try? (defaultSettings as NSDictionary).write(to: url)
    }
    
    func loadSettings() {
        guard let url = plistURL,
              let data = FileManager.default.contents(atPath: url.path),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else { return }
        
        proxyBase = plist["proxyBase"] as? String ?? ""
        keepTab = plist["keepTab"] as? Bool ?? true
        useSSL = plist["useSSL"] as? Bool ?? false
        useOpenAthens = plist["useOpenAthens"] as? Bool ?? false
        useContentScript = plist["useContentScript"] as? Bool ?? false
    }
    
    func saveSettings() {
        guard let url = plistURL else { return }
        
        let settings: [String: Any] = [
            "proxyBase": proxyBase,
            "keepTab": keepTab,
            "useSSL": useSSL,
            "useOpenAthens": useOpenAthens,
            "useContentScript": useContentScript
        ]
        
        if (try? (settings as NSDictionary).write(to: url)) != nil {
            showSuccessMessage()
            notifyExtensionOfSettingsChange()
        }
    }
    
    func validateAndSaveProxy() {
        let cleaned = cleanURL(proxyBase)
        
        if isValidDomain(cleaned) {
            proxyBase = cleaned
            saveSettings()
        } else {
            showErrorMessage()
        }
    }
    
    private func isValidDomain(_ domain: String) -> Bool {
        let pattern = "^(?!:\\/\\/)(?!.*:\\/\\/)([a-zA-Z0-9-_]+\\.)*[a-zA-Z0-9][a-zA-Z0-9-_]+\\.[a-zA-Z]{2,11}?(:[0-9]{1,5})?$"
        return domain.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func cleanURL(_ input: String) -> String {
        var cleaned = input
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "//", with: "")
        
        // Remove trailing slashes and paths
        if let slashIndex = cleaned.firstIndex(of: "/") {
            cleaned = String(cleaned[..<slashIndex])
        }
        
        // Remove whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    private func showSuccessMessage() {
        settingsMessage = "Settings saved successfully!"
        showSettingsMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showSettingsMessage = false
        }
    }
    
    private func showErrorMessage() {
        settingsMessage = "Invalid domain format. Please enter a valid domain."
        showSettingsMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showSettingsMessage = false
        }
    }
    
    func openSafariExtensionPreferences() {
        #if os(macOS)
        Task { @MainActor in
            do {
                // For Web Extensions, use the new bundle identifier
                try await SFSafariApplication.showPreferencesForExtension(
                    withIdentifier: "com.cornelius-bell.EZProxy.WebExtension"
                )
            } catch {
                print("Error opening Safari Extension preferences: \(error)")
                // Fallback: just open Safari
                NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Safari.app"))
            }
        }
        #else
        // On iOS, open the Settings app to the Safari Extensions section
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    func testProxyConnection(with testURL: String) {
        guard !proxyBase.isEmpty else { return }
        
        let base = cleanURL(proxyBase)
        var proxyURL: String
        
        if useOpenAthens {
            proxyURL = "https://go.openathens.net/redirector/\(base)?url=\(testURL)"
        } else {
            let scheme = useSSL ? "https" : "http"
            proxyURL = "\(scheme)://\(base)/login?url=\(testURL)"
        }
        
        if let url = URL(string: proxyURL) {
            #if os(macOS)
            NSWorkspace.shared.open([url], withApplicationAt: URL(fileURLWithPath: "/Applications/Safari.app"), configuration: NSWorkspace.OpenConfiguration())
            #else
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    // Setup observer for settings changes from extension
    private func setupSettingsObserver() {
        // Monitor the plist file for changes
        if let url = plistURL {
            let coordinator = NSFileCoordinator(filePresenter: nil)
            coordinator.coordinate(with: [.reading], at: url, options: .withoutChanges, error: nil) { _ in
                // Settings file exists, set up monitoring
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                    self.loadSettings()
                }
            }
        }
    }
    
    // Notify extension of settings change
    private func notifyExtensionOfSettingsChange() {
        #if os(macOS)
        // Post a notification that the extension can listen for
        DistributedNotificationCenter.default().post(
            name: Notification.Name("com.cornelius-bell.EZProxy.settingsChanged"),
            object: nil
        )
        #endif
    }
}