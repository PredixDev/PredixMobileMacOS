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

    override var representedObject: Any? {
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
        if UserDefaults.standard.value(forKey: PredixMobilityConfiguration.serverEndpointConfigKey) == nil
        {
            let storyboard = self.storyboard!
            let prefVC = storyboard.instantiateController(withIdentifier: "PreferencesViewController") as! PreferencesViewController
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
    func displaySeriousErrorPopup(_ errorMessage: String, retry: @escaping ()->())
    {
        let responseOK = 0
        let responseQuit = 0xFF
        
        let alert = NSAlert()
        alert.messageText = errorMessage
        alert.addButton(withTitle: "Ok").tag = responseOK
        alert.addButton(withTitle: "Quit").tag = responseQuit
        alert.alertStyle = .critical
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (response: NSModalResponse) in
            if response == responseQuit
            {
                exit(EXIT_FAILURE)
            }
            else
            {
                retry()
            }
        }) 

    }
    
    ///Initializes the SDK and starts it.
    func startPredixMobileSDK()
    {
        // this sets up how the serious error popup will be displayed. Alternatively, a web-based error page can be used, but for this example
        // we're using a native page. See the PredixMobileiOS project for an example of an embedded web-based error page.
        PredixMobilityConfiguration.displaySeriousErrorPopup = self.displaySeriousErrorPopup
        
        // Add optional and custom services to the system if required by adding these services to an array, and assigning that array to PredixMobilityConfiguration.additionalBootServicesToRegister.
        //PredixMobilityConfiguration.additionalBootServicesToRegister = [OpenURLService.self]
        
        PredixMobilityConfiguration.loadConfiguration()
        
        PredixMobilityConfiguration.requireDevicePasscodeSet = false

        let pmm = PredixMobilityManager(packageWindow: self, presentAuthentication: {[unowned self] (packageWindow) -> (PredixAppWindowProtocol) in
            
            let authVC = self.storyboard?.instantiateController(withIdentifier: "AuthViewController") as! NSViewController
            let authWindow = NSWindow(contentViewController: authVC)
            
            self.view.window?.beginSheet(authWindow, completionHandler: nil)
            return authVC as! PredixAppWindowProtocol
            
            }, dismissAuthentication: {[unowned self]  (authenticationWindow) -> () in
                
                if let authVC = authenticationWindow as? NSViewController
                {
                    self.view.window?.endSheet(authVC.view.window!)
                }
                self.spinner.isHidden = false
                self.spinner.startAnimation(nil)
                
            })
        
        pmm.startApp()
        
        // This notification tells the SDK the UI is ready for processing.
        // Since we're starting the SDK in a viewcontroller rather than the AppDelegate the system-level 
        // ApplicationDidBecomeActive notification that the SDK usually uses has already occured.
        NotificationCenter.default.post(name: UIReadyNotification, object: nil)
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
    
    func receiveAppNotification(_ script: String)
    {
        webView.mainFrame.javaScriptContext.evaluateScript(script)
    }
    
    //MARK: WebFrameLoadDelegate methods
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!)
    {
       
        Logger.trace("Web view finished load")
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
        
        Logger.debug("Web view encountered loading error: \(err.description)")
        ShowSeriousErrorHelper.ShowUserError(err.localizedDescription)
    }
    
    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        Logger.trace("Web view starting load")
        self.spinner.isHidden = false
        self.spinner.startAnimation(nil)
    }
}

