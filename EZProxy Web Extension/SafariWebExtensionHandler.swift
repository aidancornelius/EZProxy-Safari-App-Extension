//
//  SafariWebExtensionHandler.swift
//  EZProxy Web Extension
//
//  Handles native messaging between the web extension and the native app
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any]
        
        os_log(.default, "Received message from browser: %{public}@", String(describing: message))
        
        // Handle different message types
        if let messageType = message?["type"] as? String {
            switch messageType {
            case "getSettings":
                respondWithSettings(context: context)
            case "saveSettings":
                if let settings = message?["settings"] as? [String: Any] {
                    saveSettings(settings, context: context)
                }
            default:
                let response = NSExtensionItem()
                response.userInfo = [SFExtensionMessageKey: ["error": "Unknown message type"]]
                context.completeRequest(returningItems: [response], completionHandler: nil)
            }
        }
    }
    
    private func respondWithSettings(context: NSExtensionContext) {
        let settings = loadSettingsFromSharedContainer()
        
        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: ["type": "settingsResponse", "settings": settings]]
        
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
    
    private func saveSettings(_ settings: [String: Any], context: NSExtensionContext) {
        saveSettingsToSharedContainer(settings)
        
        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: ["type": "saveResponse", "success": true]]
        
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
    
    private func loadSettingsFromSharedContainer() -> [String: Any] {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell"
        ) else {
            return [:]
        }
        
        let plistURL = containerURL.appendingPathComponent("HK6R36PLNR.com.cornelius-bell.EZProxySettings.plist")
        
        guard let data = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return [:]
        }
        
        return plist
    }
    
    private func saveSettingsToSharedContainer(_ settings: [String: Any]) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell"
        ) else {
            return
        }
        
        let plistURL = containerURL.appendingPathComponent("HK6R36PLNR.com.cornelius-bell.EZProxySettings.plist")
        
        if let data = try? PropertyListSerialization.data(fromPropertyList: settings, format: .xml, options: 0) {
            try? data.write(to: plistURL)
        }
    }
}