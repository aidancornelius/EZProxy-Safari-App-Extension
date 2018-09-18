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

    func writeSettings( theSetting: String ) {
        let file = "EZProxy-Safari.text" //this is the file. we will write to and read from it
        
       let text = theSetting //just a text
        
        /* if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        */
        
       // let file = "EZProxy-Safari.text" //this is the file. we will write to and read from it
        
        var text2 = ""
        
        let home = FileManager.default.homeDirectoryForCurrentUser
        let safariExtDir = home.appendingPathComponent("Library/Containers/net.stemtl.EZProxy.EZProxy-Safari/Data/Documents/")
        
        let fileURL = safariExtDir.appendingPathComponent(file)
        
            //let fileURL = dir.appendingPathComponent(file)
            
        //writing
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
            
        
    }
    
    func readSettings() -> String{
        let file = "EZProxy-Safari.text" //this is the file. we will write to and read from it
        
        var text2 = ""
        
        let home = FileManager.default.homeDirectoryForCurrentUser
        let safariExtDir = home.appendingPathComponent("Library/Containers/net.stemtl.EZProxy.EZProxy-Safari/Data/Documents/")
        
        let fileURL = safariExtDir.appendingPathComponent(file)
        
        //reading
        do {
            text2 = try String(contentsOf: fileURL, encoding: .utf8)
        }
        catch {
            text2 = "ezproxy.flinders.edu.au"
        }
    
        
        return text2
    }
    
    @IBAction func updateProxyClicked(_ sender: Any) {
        NSLog("I have been asked to set the proxy URL to: " + proxyUpdateField.stringValue)
        
        writeSettings(theSetting: proxyUpdateField.stringValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proxyUpdateField.stringValue = readSettings()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

