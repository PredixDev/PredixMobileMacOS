//
//  AuthViewController.swift
//  PredixMobileMacOS
//
//  Created by Johns, Andy (GE Corporate) on 6/7/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Cocoa
import WebKit
import PredixMobileSDK

/// Handles authentication UI
class AuthViewController: NSViewController, WebFrameLoadDelegate, PredixAppWindowProtocol  {

    @IBOutlet var spinnerLabel: NSTextField!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var webView: WebView!

    var webViewFinishedLoad : (()->())?

    //MARK: NSViewController overrides
    override func viewDidAppear()
    {
        // allow the app to quit even when the login sheet is displayed
        if let window = self.view.window
        {
            window.preventsApplicationTerminationWhenModal = false

            //prevent sheet from being able to shrink
            window.minSize = window.frame.size
            
            //prevent sheet from being able to grow larger than the parent window.
            if let sheetParent = window.sheetParent
            {
                window.maxSize = sheetParent.frame.size
            }
        }
    }
    

    //MARK: PredixAppWindowProtocol methods
    func loadURL(_ URL: Foundation.URL, parameters: [AnyHashable: Any]?, onComplete: (() -> ())?)
    {
        if let onComplete = onComplete
        {
            self.webViewFinishedLoad = onComplete
        }
        
        webView.mainFrame.load(URLRequest(url: URL))
    }
    
    func updateWaitState(_ state: PredixMobileSDK.WaitState, message: String?)
    {
        switch state
        {
        case .notWaiting :
            self.spinner.stopAnimation(nil)
            self.spinner.isHidden = true
            self.spinnerLabel.cell?.title = ""
            self.spinnerLabel.isHidden = true
            
        case .waiting :
            
            self.spinner.isHidden = false
            self.spinnerLabel.isHidden = false
            self.spinner.startAnimation(nil)
            self.spinnerLabel.cell?.title = message ?? ""
        }
    }
    func waitState() -> (PredixMobileSDK.WaitStateReturn)
    {
        return WaitStateReturn(state: self.spinner.isHidden ? .notWaiting : .waiting, message: self.spinnerLabel.cell?.title)
    }
    
    
    //MARK: WebFrameLoadDelegate methods
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!)
    {
        
        Logger.trace("Authentication web view finished load")
        self.spinner.isHidden = true
        self.spinner.stopAnimation(nil)
        if let webViewFinishedLoad = self.webViewFinishedLoad
        {
            self.webViewFinishedLoad = nil
            webViewFinishedLoad()
        }
    }
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!)
    {
        self.spinner.isHidden = true
        self.spinner.stopAnimation(nil)
        
        let err = error as NSError
        
        // Ignore cancelled and "Frame Load Interrupted" errors
        if err.code == NSURLErrorCancelled {return}
        if err.code == 102 && err.domain == "WebKitErrorDomain" {return}
        
        Logger.debug("Authentication web view encountered loading error: \(err.description)")
        ShowSeriousErrorHelper.ShowUserError(err.localizedDescription)
    }
    
    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        Logger.trace("Authentication web view starting load")
        self.spinner.isHidden = false
        self.spinner.startAnimation(nil)
    }

}
