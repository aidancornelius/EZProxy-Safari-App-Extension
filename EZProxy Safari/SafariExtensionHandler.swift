//
//  SafariExtensionHandler.swift
//  EZProxy Safari
//
//  Created by Aidan Cornelius-Bell on 18/9/18.
//  Copyright © 2018 Aidan Cornelius-Bell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    func readSettings() -> String{
        let file = "EZProxy-Base-URL.text" //this is the file. we will write to and read from it
        
        var text2 = ""
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                text2 = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                text2 = "aidan.cornelius-bell.com"
            }
        }
        
        return text2
    }
    
    func readTabClosePreference() -> String {
        // logic to allow a tab to close if user requests
        let file = "EZProxy-CloseTab-Preference.text" // preference for tab close
        var text2 = ""
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                text2 = try String(contentsOf: fileURL, encoding: .utf8)
            } catch {
                text2 = "keep" // default to keep the tab
            }
        }
                            
        return text2
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
                        let libproxy = self.readSettings()
                        
                        let newURLString = "http://" + libproxy + "/login?url=http://" + host! + path!
                        
                        let completeLibProxURL = URL(string: newURLString)
                        
                        if self.readTabClosePreference() == "close" {
                            activeTab!.close()
                        }
                        
                        window.openTab(with: completeLibProxURL!, makeActiveIfPossible: true, completionHandler: nil)
                        
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
