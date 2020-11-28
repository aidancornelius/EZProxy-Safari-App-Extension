//
//  ViewController.swift
//  EZProxy
//
//  Created by Aidan Cornelius-Bell on 18/9/18.
//  Copyright © 2018 Aidan Cornelius-Bell. All rights reserved.
//

import Cocoa
import SafariServices

class ViewController: NSViewController {

    @IBOutlet weak var proxyUpdateField: NSTextField!
    @IBOutlet weak var tabCloseBehaviour: NSSegmentedControl!
    @IBOutlet weak var useSSLBehaviour: NSButton!
    
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
                "proxyBase": "ezproxy.flinders.edu.au",
                "keepTab": true,
                "useSSL": false,
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
    
    func writeSettings( proxyBase: String? = nil, keepTab: Bool? = nil, useSSL: Bool? = nil ) ->Bool {
        var newProxyBase = ""
        var newKeepTab = false
        var newUseSSL = false
        
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
        
        let data : [String: Any] =
            ["proxyBase": newProxyBase,
             "keepTab": newKeepTab,
             "useSSL": newUseSSL,]
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
    
    /* Debugging states of the checkbox and the plist 
    @IBAction func updateUseSSLButton(_ sender: Any) {
        let a = String(useSSLBehaviour.state.rawValue)
        let b = getDataFromPlist( theKey: "useSSL" )
        
        let states = "\(a) \(b)"
        
        alertDialog(question: "Does this seem right?", text: states)
    } */
    
    func updateUseSSLSettings() {
        if ( getDataFromPlist( theKey: "useSSL" ) as! Bool == true) {
            // it is 'true' let's make the button the same
            if useSSLBehaviour.state.rawValue == 0 {
                useSSLBehaviour.setNextState()
            }
        } else {
            // it is 'false' let's make the button the same
            if useSSLBehaviour.state.rawValue == 1 {
                useSSLBehaviour.setNextState()
            }
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
        
        _ = writeSettings(proxyBase: proxyUpdateField.stringValue)
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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

