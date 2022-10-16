//
//  ViewController.swift
//  EZProxy
//
//  Created by Aidan Cornelius-Bell on 18/9/18.
//  Copyright © 2018 Aidan Cornelius-Bell. All rights reserved.
//

import Cocoa
import SafariServices

extension String: Error {}

class ViewController: NSViewController {

    @IBOutlet weak var proxyUpdateField: NSTextField!
    @IBOutlet weak var tabCloseBehaviour: NSSegmentedControl!
    @IBOutlet weak var useSSLBehaviour: NSButton!
    @IBOutlet weak var configurationIndicator: NSLevelIndicator!
    @IBOutlet weak var configurationText: NSTextField!
    @IBOutlet weak var openAthens: NSButton!
    
    @IBOutlet weak var descriptionForProxyURL: NSTextFieldCell!
    
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
    
    /* Debugging states of the checkbox and the plist 
    @IBAction func updateUseSSLButton(_ sender: Any) {
        let a = String(useSSLBehaviour.state.rawValue)
        let b = getDataFromPlist( theKey: "useSSL" )
        
        let states = "\(a) \(b)"
        
        alertDialog(question: "Does this seem right?", text: states)
    } */
    
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
                    descriptionForProxyURL.stringValue = "You have selected OpenAthens as the proxy provider. Enter your OA identifier (typically the same as the main domain something.edu)."
                } else {
                    // Okay, so its false!
                    if openAthens.state.rawValue == 1 {
                        openAthens.setNextState()
                    }
                }
            }
        } catch {
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
    
    @IBAction func updateProxyClicked(_ sender: Any) {
        NSLog("I have been asked to set the proxy URL to: " + proxyUpdateField.stringValue)
        
        configurationIndicator.isHidden = false
        configurationText.isHidden = false
        
        let adjustments = [
            (pattern: "\\s*(\\.\\.\\.|\\.|,)\\s*", replacement: "$1"), // elipsis or period or comma has trailing space
            (pattern: "\\s*'\\s*", replacement: "'"), // apostrophe has no extra space
            (pattern: "^\\s+|\\s+$", replacement: ""), // remove leading or trailing space
            (pattern: "^(http|https)://", replacement: ""),
        ]
        
        let mutableString = NSMutableString(string: proxyUpdateField.stringValue)
        
        for (pattern, replacement) in adjustments {
            let re = try! NSRegularExpression(pattern: pattern)
            re.replaceMatches(in: mutableString,
                              options: [],
                              range: NSRange(location: 0, length: mutableString.length),
                              withTemplate: replacement)
        }
        
        let regString = String(mutableString)
        
        let regmatchUrl = #"[a-zA-Z]\w*(\.\w+)+(/\w*(\.\w+)*)*(\?.+)*\/"#
        let result = regString.range(of: regmatchUrl, options: .regularExpression)
        if result != nil {
            configurationIndicator.integerValue = 3
        } else {
            configurationIndicator.integerValue = 1
        }
        
        proxyUpdateField.stringValue = regString
        
        _ = writeSettings(proxyBase: regString)
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
        configurationIndicator.isHidden = true
        configurationText.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

