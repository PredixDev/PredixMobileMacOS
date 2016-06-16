//
//  PreferencesViewController.swift
//  PredixMobileMacOS
//
//  Created by Johns, Andy (GE Corporate) on 6/8/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Cocoa
import PredixMobileSDK

/// Handles preferences UI. This UI is used both for the Preference menu item, 
/// and as a popup when first starting the app if required settings have not been set
class PreferencesViewController: NSViewController, NSTextFieldDelegate {

    var initalStartup = false
    @IBOutlet var saveButton: NSButton!
    @IBOutlet var serverInput: NSTextField!
    @IBOutlet var loggingLevelLabel: NSTextField!
    @IBOutlet var loggingLevelSlider: NSSlider!
    @IBOutlet var traceRequestsButton: NSButton!
    
    
    //MARK: NSViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {

        self.loadSettings()
        
        self.loggingLevelSlider.sendActionOn(Int(NSEventMask([NSEventMask.LeftMouseDraggedMask, NSEventMask.LeftMouseUpMask]).rawValue))
        
        self.saveButton.hidden = !self.initalStartup
        self.saveButton.enabled = self.serverInput.cell!.title.characters.count > 0
        
        if let window = self.view.window where self.initalStartup
        {
            // allow app to close even if this sheet is showing.
            window.preventsApplicationTerminationWhenModal = false
            
            //When displayed as a sheet, prevent from being able to resize
            window.minSize = window.frame.size
            window.maxSize = window.frame.size
        }
    }
    
    override func viewWillDisappear()
    {
        self.releaseServerField()
        self.saveSettings()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        self.releaseServerField()
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        self.saveButton.enabled = self.serverInput.cell!.title.characters.count > 0
    }
    
    
    //MARK: IBActions
    @IBAction func saveClicked(sender: AnyObject)
    {
        self.saveSettings()
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSModalResponseOK)
    }

    @IBAction func traceRequestsChanged(sender: NSButton)
    {
        self.releaseServerField()
        
    }
    @IBAction func loggingLevelSliderChanged(sender: NSSlider)
    {
        self.setLoggingLevelDescription(self.loggingLevelSlider.integerValue)
        self.releaseServerField()
    }

    
    //MARK: Class methods
    
    ///Saves changes made in the UI to NSDefaults.
    func saveSettings()
    {
        // don't save if there is no server endpoint configured.
        if self.serverInput.cell?.title != ""
        {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setValue(self.traceRequestsButton.state == 1, forKey: PredixMobilityConfiguration.traceLogsRequestsConfigKey)
            defaults.setValue(self.loggingLevelSlider.integerValue, forKey: PredixMobilityConfiguration.loggingLevelConfigKey)
            defaults.setValue(self.serverInput.cell!.title, forKey: PredixMobilityConfiguration.serverEndpointConfigKey)
            
            defaults.synchronize()
        }
    }
    
    // Initializes the UI with settings stored in NSDefaults.
    func loadSettings()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let value = defaults.valueForKey(PredixMobilityConfiguration.traceLogsRequestsConfigKey), boolValue = value as? Bool
        {
            self.traceRequestsButton.state = boolValue ? 1 : 0
        }
        else
        {
            self.traceRequestsButton.state = PredixMobilityConfiguration.traceLogsAllRequestsDefault ? 1 : 0
        }
        
        if let value = defaults.valueForKey(PredixMobilityConfiguration.loggingLevelConfigKey), intValue = value as? Int
        {
            self.loggingLevelSlider.integerValue = intValue
        }
        else
        {
            self.loggingLevelSlider.integerValue = Int(PredixMobilityConfiguration.defaultLoggingLevel.rawValue)
        }
        
        self.setLoggingLevelDescription(self.loggingLevelSlider.integerValue)
        
        if let value = defaults.valueForKey(PredixMobilityConfiguration.serverEndpointConfigKey), serverEndpoint = value as? String
        {
            self.serverInput.cell!.title = serverEndpoint
        }
    }
    
    //Translates logging levels to string descriptions.
    func setLoggingLevelDescription(level: Int)
    {
        switch PGSDKLoggerLevelEnum(UInt32(level))
        {
            case PGSDKLoggerLevelOff : self.loggingLevelLabel.cell!.title = "None"
            case PGSDKLoggerLevelFatal : self.loggingLevelLabel.cell!.title = "Fatal"
            case PGSDKLoggerLevelError : self.loggingLevelLabel.cell!.title = "Error"
            case PGSDKLoggerLevelWarn : self.loggingLevelLabel.cell!.title = "Warn"
            case PGSDKLoggerLevelInfo : self.loggingLevelLabel.cell!.title = "Info"
            case PGSDKLoggerLevelDebug : self.loggingLevelLabel.cell!.title = "Debug"
            case PGSDKLoggerLevelTrace : self.loggingLevelLabel.cell!.title = "Trace"
            default: self.loggingLevelLabel.cell!.title = ""
        }
        
    }

    //prompts the completion of text editing in the server hostname field when user interacts with a different part of the UI,
    //and when in initial popup mode, ensures the save button is enabled or disabled based on if the server hostname has been entered.
    func releaseServerField()
    {
        self.serverInput.window?.makeFirstResponder(nil)
        self.saveButton.enabled = self.serverInput.cell!.title.characters.count > 0
    }

}
