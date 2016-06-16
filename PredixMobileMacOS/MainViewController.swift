//
//  MainViewController.swift
//  PredixMobileMacOS
//
//  Created by Johns, Andy (GE Corporate) on 6/7/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Cocoa
import WebKit
import PredixMobileSDK

/// Primary UI of the app
class MainViewController: NSViewController, WebFrameLoadDelegate, PredixAppWindowProtocol {

    @IBOutlet var spinnerLabel: NSTextField!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var webView: WebView!

    var webViewFinishedLoad : (()->())?

    //MARK: NSViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.view.window?.preventsApplicationTerminationWhenModal = false
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillAppear()
    {
        self.startApp()
    }
    
    //MARK: class methods
    
    ///Validates that we have established our initial settings (like server hostname) and then initializes the SDK.
    ///If needed, other initialization would be included here.
    func startApp()
    {
        // ensure the first time we launch we have all the settings we expect.
        self.validateKeyPreferences()
    }
    
    ///Validates that we have established our initial settings (like server hostname)
    func validateKeyPreferences()
    {
        if NSUserDefaults.standardUserDefaults().valueForKey(PredixMobilityConfiguration.serverEndpointConfigKey) == nil
        {
            let storyboard = self.storyboard!
            let prefVC = storyboard.instantiateControllerWithIdentifier("PreferencesViewController") as! PreferencesViewController
            prefVC.initalStartup = true
            
            
            let prefWindow = NSWindow(contentViewController: prefVC)
            
            self.view.window?.beginSheet(prefWindow, completionHandler: {[unowned self] (_:NSModalResponse) in
                self.validateKeyPreferences()
                })
        }
        else
        {
            startPredixMobileSDK()
        }
    }

    ///Displays a native error popup in the event of a error that prevents the SDK from loading the initial webapp.
    func displaySeriousErrorPopup(errorMessage: String, retry: ()->())
    {
        let responseOK = 0
        let responseQuit = 0xFF
        
        let alert = NSAlert()
        alert.messageText = errorMessage
        alert.addButtonWithTitle("Ok").tag = responseOK
        alert.addButtonWithTitle("Quit").tag = responseQuit
        alert.alertStyle = .CriticalAlertStyle
        
        alert.beginSheetModalForWindow(self.view.window!) { (response: NSModalResponse) in
            if response == responseQuit
            {
                exit(EXIT_FAILURE)
            }
            else
            {
                retry()
            }
        }

    }
    
    ///Initializes the SDK and starts it.
    func startPredixMobileSDK()
    {
        // this sets up how the serious error popup will be displayed. Alternatively, a web-based error page can be used, but for this example
        // we're using a native page. See the PredixMobileiOS project for an example of an embedded web-based error page.
        PredixMobilityConfiguration.displaySeriousErrorPopup = self.displaySeriousErrorPopup
        
        PredixMobilityConfiguration.loadConfiguration()
        
        let pmm = PredixMobilityManager(packageWindow: self, presentAuthentication: {[unowned self] (packageWindow) -> (PredixAppWindowProtocol) in
            
            let authVC = self.storyboard?.instantiateControllerWithIdentifier("AuthViewController") as! NSViewController
            let authWindow = NSWindow(contentViewController: authVC)
            
            self.view.window?.beginSheet(authWindow, completionHandler: nil)
            return authVC as! PredixAppWindowProtocol
            
            }, dismissAuthentication: {[unowned self]  (authenticationWindow) -> () in
                
                if let authVC = authenticationWindow as? NSViewController
                {
                    self.view.window?.endSheet(authVC.view.window!)
                }
                self.spinner.hidden = false
                self.spinner.startAnimation(nil)
                
            })
        
        pmm.startApp()
        
        // This notification tells the SDK the UI is ready for processing.
        // Since we're starting the SDK in a viewcontroller rather than the AppDelegate the system-level 
        // ApplicationDidBecomeActive notification that the SDK usually uses has already occured.
        NSNotificationCenter.defaultCenter().postNotificationName(UIReadyNotification, object: nil)
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
    
    func receiveAppNotification(script: String)
    {
        webView.mainFrame.javaScriptContext.evaluateScript(script)
    }
    
    //MARK: WebFrameLoadDelegate methods
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!)
    {
       
        PGSDKLogger.trace("Web view finished load")
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
        
        PGSDKLogger.debug("Web view encountered loading error: \(error.description)")
        ShowSeriousErrorHelper.ShowUserError(error.localizedDescription)
    }
    
    func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
        PGSDKLogger.trace("Web view starting load")
        self.spinner.hidden = false
        self.spinner.startAnimation(nil)
    }
}

