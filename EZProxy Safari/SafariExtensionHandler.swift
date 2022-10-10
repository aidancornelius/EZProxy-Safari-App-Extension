//
//  SafariExtensionHandler.swift
//  EZProxy Safari
//
//  Created by Aidan Cornelius-Bell on 18/9/18.
//  Copyright © 2018 Aidan Cornelius-Bell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    func getDataFromPlist( theKey: String ) -> Any {

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
    
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        window.getActiveTab(completionHandler: { (activeTab) in
            
            activeTab?.getActivePage(completionHandler:  { (activePage) in
                
                activePage?.getPropertiesWithCompletionHandler( { (properties) in
                    
                    if properties?.url != nil {
                        let urlString = properties!.url!.absoluteString
                        
                        let url = URL(string: urlString)
                        let host = url?.host
                        let path = url?.path
                        let libproxy = self.getDataFromPlist( theKey: "proxyBase" ) as! String
                        var ssl = ""
                        if self.getDataFromPlist(theKey: "useSSL") as! Bool { ssl = "https://"} else { ssl = "http://" }
                        
                        let newURLString = ssl + libproxy + "/login?url=http://" + host! + path!
                        
                        var completeLibProxURL = URL(string: newURLString)
                        
                        if self.getDataFromPlist(theKey: "useOpenAthens") as! Bool {
                            // using OpenAthens to jump...
                            let oabase = "https://go.openathens.net/redirector/" + libproxy + "?url=http://" + host!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + path!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            completeLibProxURL = URL(string: oabase)
                        }
                        
                        // Now running the tab open earlier (not making it active)
                        if self.getDataFromPlist( theKey: "keepTab" ) as! Bool == false {
                            window.openTab(with: completeLibProxURL!, makeActiveIfPossible: false, completionHandler: nil)
                            // Fixes Issue #9: closes the active tab (if last window open) after creating the new window, but doesn't make it active – doesn't need to, because the active tab is closed and Safari automatically opens the child tab(s) next
                            activeTab!.close()
                        } else {
                            // resumes the default behaviour of making the tab active
                            window.openTab(with: completeLibProxURL!, makeActiveIfPossible: true, completionHandler: nil)
                        }
                        
                    }
                })
            })
        })
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
