//
//  TestViewController.swift
//  EZProxy
//
//  Created by Aidan Cornelius-Bell on 4/11/2023.
//  Copyright © 2023 Aidan Cornelius-Bell. All rights reserved.
//

import Cocoa
import WebKit

class TestViewController: NSViewController, WKNavigationDelegate {

    @IBOutlet weak var testWebView: WKWebView!
    
    // adapted from https://stackoverflow.com/a/29433631
    func alertDialog(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Okay")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the navigation delegate to self
        testWebView.navigationDelegate = self
                
        let urlString = "https://doi.org/10.1007/s10734-022-00972-z"
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
        
        // Outrageously we have to wrap this in a request before we can load it in the webview...
        let request = URLRequest(url: completeLibProxURL!)
        self.testWebView.load(request)
    }
    
    // Handle errors that occur during the main navigation
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        _ = alertDialog(question: "Navigation error", text: "\(error.localizedDescription)")
    }

    // Handle errors that occur during the initial content load
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        _ = alertDialog(question: "Provisional navigation error", text: "\(error.localizedDescription)")
    }
    
    // Optionally, handle server-side errors like 404s
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        // This can be used to handle server-side redirects
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Navigation finished successfully
        print("Navigation finished successfully")
    }
    
}
