//
//  HelpViewController.swift
//  EZProxy
//
//  Created by Aidan Cornelius-Bell on 20/12/2022.
//  Copyright © 2022 Aidan Cornelius-Bell. All rights reserved.
//

import Cocoa
import WebKit

class HelpViewController: NSViewController {

    @IBOutlet weak var helpWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let indexURL = Bundle.main.url(forResource: "ezp-help",
                                          withExtension: "html") {
            
            self.helpWebView.loadFileURL(indexURL,
                                         allowingReadAccessTo: indexURL)
            
            
        }
    }
    
}
