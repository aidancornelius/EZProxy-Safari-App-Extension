//
//  ViewController.swift
//  EZProxy
//
//  Created by Aidan Cornelius-Bell on 18/9/18.
//  Copyright © 2018 Aidan Cornelius-Bell. All rights reserved.
//

import Foundation
import Cocoa
import SafariServices

extension String: Error {}

class ViewController: NSViewController {

    @IBOutlet weak var proxyUpdateField: NSTextField!
    @IBOutlet weak var tabCloseBehaviour: NSSegmentedControl!
    @IBOutlet weak var useSSLBehaviour: NSButton!
    @IBOutlet weak var openAthens: NSButton!
    @IBOutlet weak var descriptionForProxyURL: NSTextFieldCell!
    @IBOutlet weak var settingsOkay: NSTextField!
    
    // adapted from https://stackoverflow.com/a/29433631
    func alertDialog(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Okay")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func createPlistForDataStorage() {
        let fileManager = FileManager.default
        
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell")?.appendingPathComponent("HK6R36PLNR.com.cornelius-bell.EZProxySettings.plist")
        
        if(!fileManager.fileExists(atPath: url!.path)){
            let data : [String: Any] = [
                "proxyBase": "proxy.slsa.sa.gov.au",
                "keepTab": true,
                "useSSL": false,
                "useOpenAthens": false
            ]

            if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell") {
                let newDirectory = directory.appendingPathComponent("Backups")
                try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            }
            
            let someData = NSDictionary(dictionary: data)
            do {
                let isWritten = try someData.write(to: url!)
                print("Creating settings plist: \(isWritten)")
            } catch {
                print(error)
            }
        } else {
            print("Settings plist exists")
        }
    }
    
    func getDataFromPlist( theKey: String ) -> Any {
        createPlistForDataStorage()
        
        let fileManager = FileManager.default
        
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell")?.appendingPathComponent("HK6R36PLNR.com.cornelius-bell.EZProxySettings.plist")
        
        let plistXML = fileManager.contents(atPath: url!.path)
        
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        var plistData: [String: AnyObject] = [:]
        
        do {
            plistData = try PropertyListSerialization.propertyList(from: plistXML!, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]
        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
        
        let data = plistData[theKey]
        
        return data ?? "nil"
    }

    
    func writeToPlist( data : [String: Any] ) ->Bool{
        let fileManager = FileManager.default
        
        let url = (fileManager.containerURL(forSecurityApplicationGroupIdentifier: "HK6R36PLNR.com.cornelius-bell")?.appendingPathComponent("HK6R36PLNR.com.cornelius-bell.EZProxySettings.plist"))!
        let someData = NSDictionary(dictionary: data)
        do {
            let isWritten = try someData.write(to: url)
            print("Creating settings plist: \(isWritten)")
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func writeSettings( proxyBase: String? = nil, keepTab: Bool? = nil, useSSL: Bool? = nil, useOpenAthens: Bool? = nil) ->Bool {
        var newProxyBase = ""
        var newKeepTab = false
        var newUseSSL = false
        var newUseOpenAthens = false
        
        if (proxyBase != nil) {
            newProxyBase = proxyBase!
        } else {
            newProxyBase = getDataFromPlist(theKey: "proxyBase") as! String
        }
        if (keepTab != nil) {
            newKeepTab = keepTab!
        } else {
            newKeepTab = getDataFromPlist(theKey: "keepTab") as! Bool
        }
        if (useSSL != nil) {
            newUseSSL = useSSL!
        } else {
            newUseSSL = getDataFromPlist(theKey: "useSSL") as! Bool
        }
        if (useOpenAthens != nil) {
            newUseOpenAthens = useOpenAthens!
        } else {
            newUseOpenAthens = getDataFromPlist(theKey: "useOpenAthens") as! Bool
        }
        
        let data : [String: Any] =
            ["proxyBase": newProxyBase,
             "keepTab": newKeepTab,
             "useSSL": newUseSSL,
             "useOpenAthens": newUseOpenAthens,
            ]
        return writeToPlist(data: data)
    }
    
    func readProxySettings() -> String {
        getDataFromPlist( theKey: "proxyBase" ) as! String
    }
    
    func updateKeepTabSettings() {
        let keepTab = getDataFromPlist(theKey: "keepTab") as! Bool
        
        if (keepTab == true) {
            tabCloseBehaviour.setSelected(true, forSegment: 1)
            tabCloseBehaviour.setSelected(false, forSegment: 0)
        } else {
            tabCloseBehaviour.setSelected(false, forSegment: 1)
            tabCloseBehaviour.setSelected(true, forSegment: 0)
        }
    }
    
    func upgradePlistTasks() -> Bool {
        // add the oA property if it's missing then do whatever else
        if writeSettings(useOpenAthens: false) {
            return true;
        } else {
            return false;
        }
        // Any subsequent new plist items can go here...
    }
    
    func updateUseSSLSettings() {
        if ( getDataFromPlist( theKey: "useSSL" ) as! Bool == true) {
            // it is 'false' let's make the button the same
            if useSSLBehaviour.state.rawValue == 0 {
                useSSLBehaviour.setNextState()
            }
        } else {
            // it is 'true' let's make the button the same
            if useSSLBehaviour.state.rawValue == 1 {
                useSSLBehaviour.setNextState()
            }
        }
    }
    
    func updateUseOpenAthens() {
        do {
            guard let useOpenAthens = getDataFromPlist(theKey: "useOpenAthens") as? Bool else {
                throw "There may not be an oA key in the plist?"
            }
            if ( useOpenAthens as! Bool == true) {
                // it's true, update our button
                if openAthens.state.rawValue == 0 {
                    openAthens.setNextState()
                } else {
                    // Okay, so its false!
                    if openAthens.state.rawValue == 1 {
                        openAthens.setNextState()
                    }
                }
            }
        } catch {
            // This calls to add the key for useOpenAthens FUTURE ITERATIONS: may need a variable to determine what to add? Incremental upgrades, and all that.
            upgradePlistTasks()
        }
    }
    
    /* Are we using OpenAthens? Let's do some work here... */
    @IBAction func updateUseOpenAthens(_ sender: Any) {
        if (openAthens.state.rawValue == 1) {
            _ = writeSettings(useOpenAthens: true)
        } else {
            _ = writeSettings(useOpenAthens: false)
        }
    }
    
    
    @IBAction func useSSLClicked(_ sender: Any) {
        if (useSSLBehaviour.state.rawValue == 1) {
            _ = writeSettings(useSSL: true)
        } else {
            _ = writeSettings(useSSL: false)
        }
    }
    
    func isValidDomain(_ domain: String) -> Bool {
        // Regex pattern to match the domain name with optional port but no protocol or path
        let pattern = "^(?!http:\\/\\/|https:\\/\\/)([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\\.)+[a-zA-Z]{2,}(\\:[0-9]+)?$"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsRange = NSRange(domain.startIndex..<domain.endIndex, in: domain)
            let matches = regex.matches(in: domain, options: [], range: nsRange)
            return matches.count > 0
        } catch {
            print(error)
            return false
        }
    }
    
    func cleanURL(_ urlString: String) -> String {
        // Pattern to find the protocol and capture the domain with optional port
        let pattern = "^(?:https?:\\/\\/)?([^\\/\\?#]+)(?::(\\d+))?"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: urlString.utf16.count)
            
            if let match = regex.firstMatch(in: urlString, options: [], range: range) {
                // Extract the domain and port from the URL
                let domainRange = match.range(at: 1)
                let portRange = match.range(at: 2)
                
                var cleanString = ""
                
                if let domainRange = Range(domainRange, in: urlString) {
                    cleanString = String(urlString[domainRange])
                }
                
                if let portRange = Range(portRange, in: urlString), !portRange.isEmpty {
                    cleanString += ":" + String(urlString[portRange])
                }
                
                return cleanString
            }
            
            return urlString // If the regex doesn't match, return the original URL
        } catch {
            print("Invalid regex pattern: \(error.localizedDescription)")
            return urlString
        }
    }

    
    @IBAction func updateProxyClicked(_ sender: Any) {
        NSLog("I have been asked to set the proxy URL to: " + proxyUpdateField.stringValue + " ...")
        
        // Validate the domain first...
        let result = isValidDomain(proxyUpdateField.stringValue)
        // Clean the string anyway because users keep breaking this...
        let proxyBaseString = cleanURL(proxyUpdateField.stringValue)
        
        NSLog("... But I am setting it to: " + proxyUpdateField.stringValue + " – instead.")
        
        if result == false {
            _ = alertDialog(question: "Incorrect domain", text: "You asked to use " + proxyUpdateField.stringValue + " as the domain base but this is likely incorrect. I have automatically updated it to: " + proxyBaseString + ". You can tweak this in settings if needed.")
        } else {
            settingsOkay.isHidden = false
        }
        
        proxyUpdateField.stringValue = proxyBaseString
        
        _ = writeSettings(proxyBase: proxyBaseString)
    }
    
    @IBAction func tabCloseBehaviourDidChange(_ sender: Any) {
        // blah blah
        if tabCloseBehaviour.selectedSegment == 1 {
            // Keep original tab
            _ = writeSettings(keepTab: true)
        } else {
            // Close original tab
           _ = writeSettings(keepTab: false)
        }
    }
    
    @IBAction func safariButtonPressed(_ sender: Any) {
        // Suggestion from https://github.com/aidancornelius/EZProxy-Safari-App-Extension/issues/3#issue-588910444
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.cornelius-bell.EZProxy.EZProxy-Safari") {
            error in if let _ = error {
                _ = self.alertDialog(question: "Preference Error", text: "An error occured opening preferences in Safari. Please launch Safari and go to Preferences > Extensions.")
            }
        }
    }
    
    override func viewWillAppear() {
        createPlistForDataStorage()
        print(getDataFromPlist(theKey: "proxyBase"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proxyUpdateField.stringValue = readProxySettings()
        updateKeepTabSettings()
        updateUseSSLSettings()
        updateUseOpenAthens()
        settingsOkay.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

