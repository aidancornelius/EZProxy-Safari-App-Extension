//
//  ViewController.swift
//  EZProxy
//
//  Created by Aidan Cornelius-Bell on 18/9/18.
//  Copyright © 2018 Aidan Cornelius-Bell. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var proxyUpdateField: NSTextField!
    @IBOutlet weak var tabCloseBehaviour: NSSegmentedControl!
    @IBOutlet weak var useSSLBehaviour: NSButton!
    
    func createPlistForDataStorage() {
        let fileManager = FileManager.default
        
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "com.cornelius-bell")?.appendingPathComponent("com.cornelius-bell.EZProxySettings.plist")
        
        if(!fileManager.fileExists(atPath: url!.path)){
            let data : [String: Any] = [
                "proxyBase": "ezproxy.flinders.edu.au",
                "keepTab": true,
                "useSSL": false,
            ]

            if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "com.cornelius-bell") {
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
        
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "com.cornelius-bell")?.appendingPathComponent("com.cornelius-bell.EZProxySettings.plist")
        
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
        
        let url = (fileManager.containerURL(forSecurityApplicationGroupIdentifier: "com.cornelius-bell")?.appendingPathComponent("com.cornelius-bell.EZProxySettings.plist"))!
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
            newProxyBase = proxyBase as! String
        } else {
            newProxyBase = getDataFromPlist(theKey: "proxyBase") as! String
        }
        if (keepTab != nil) {
            newKeepTab = keepTab as! Bool
        } else {
            newKeepTab = getDataFromPlist(theKey: "keepTab") as! Bool
        }
        if (useSSL != nil) {
            newUseSSL = useSSL as! Bool
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
    
    func updateUseSSLSettings() {
        if ( getDataFromPlist( theKey: "useSSL" ) as! Bool == true) {
            
        } else {
            useSSLBehaviour.setNextState()
        }
    }
    
    @IBAction func useSSLClicked(_ sender: Any) {
        if (useSSLBehaviour!.state == NSControl.StateValue(rawValue: 0)) {
            writeSettings(useSSL: true)
        } else {
            writeSettings(useSSL: false)
        }
    }
    
    @IBAction func updateProxyClicked(_ sender: Any) {
        NSLog("I have been asked to set the proxy URL to: " + proxyUpdateField.stringValue)
        
        writeSettings(proxyBase: proxyUpdateField.stringValue)
    }
    
    @IBAction func tabCloseBehaviourDidChange(_ sender: Any) {
        // blah blah
        if tabCloseBehaviour.selectedSegment == 1 {
            // Keep original tab
            writeSettings(keepTab: true)
        } else {
            // Close original tab
           writeSettings(keepTab: false)
        }
    }
    
    @IBAction func safariButtonPressed(_ sender: Any) {
        NSWorkspace.shared.open(
            URL(string:"https://github.com/aidancornelius/EZProxy-Safari-App-Extension")!
        )
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

