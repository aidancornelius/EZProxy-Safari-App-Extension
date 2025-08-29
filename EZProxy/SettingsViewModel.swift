//
//  SettingsViewModel.swift
//  EZProxy
//
//  Handles settings persistence and validation
//

import Foundation
import SwiftUI
import SafariServices

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
        // Open Safari and trigger the Extensions preferences
        // The showPreferencesForExtension API works when called from the main app
        // It opens Safari > Settings > Extensions with your extension highlighted
        Task { @MainActor in
            do {
                try await SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.cornelius-bell.EZProxy.EZProxy-Safari")
            } catch {
                print("Error opening Safari Extension preferences: \(error)")
                // Fallback: just open Safari
                NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Safari.app"))
            }
        }
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
            // Force open in Safari specifically
            NSWorkspace.shared.open([url], withApplicationAt: URL(fileURLWithPath: "/Applications/Safari.app"), configuration: NSWorkspace.OpenConfiguration())
        }
    }
}