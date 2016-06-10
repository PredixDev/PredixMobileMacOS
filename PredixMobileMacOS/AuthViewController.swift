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
        }
    }
    

    //MARK: PredixAppWindowProtocol methods
    func loadURL(URL: NSURL, parameters: [NSObject : AnyObject]?, onComplete: (() -> ())?)
    {
        if let onComplete = onComplete
        {
            self.webViewFinishedLoad = onComplete
        }
        
        webView.mainFrame.loadRequest(NSURLRequest(URL: URL))
    }
    
    func updateWaitState(state: PredixMobileSDK.WaitState, message: String?)
    {
        switch state
        {
        case .NotWaiting :
            self.spinner.stopAnimation(nil)
            self.spinner.hidden = true
            self.spinnerLabel.cell?.title = ""
            self.spinnerLabel.hidden = true
            
        case .Waiting :
            
            self.spinner.hidden = false
            self.spinnerLabel.hidden = false
            self.spinner.startAnimation(nil)
            self.spinnerLabel.cell?.title = message ?? ""
        }
    }
    func waitState() -> (PredixMobileSDK.WaitStateReturn)
    {
        return WaitStateReturn(state: self.spinner.hidden ? .NotWaiting : .Waiting, message: self.spinnerLabel.cell?.title)
    }
    
    
    //MARK: WebFrameLoadDelegate methods
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!)
    {
        
        PGSDKLogger.trace("Authentication web view finished load")
        self.spinner.hidden = true
        self.spinner.stopAnimation(nil)
        if let webViewFinishedLoad = self.webViewFinishedLoad
        {
            self.webViewFinishedLoad = nil
            webViewFinishedLoad()
        }
    }
    
    func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!)
    {
        self.spinner.hidden = true
        self.spinner.stopAnimation(nil)
        
        guard let error = error else
        {
            // no error object, nothing to do...
            return
        }
        
        // Ignore cancelled and "Frame Load Interrupted" errors
        if error.code == NSURLErrorCancelled {return}
        if error.code == 102 && error.domain == "WebKitErrorDomain" {return}
        
        PGSDKLogger.debug("Authentication web view encountered loading error: \(error.description)")
        ShowSeriousErrorHelper.ShowUserError(error.localizedDescription)
    }
    
    func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
        PGSDKLogger.trace("Authentication web view starting load")
        self.spinner.hidden = false
        self.spinner.startAnimation(nil)
    }

}
