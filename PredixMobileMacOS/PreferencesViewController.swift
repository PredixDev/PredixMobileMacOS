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
        
        self.loggingLevelSlider.sendAction(on: NSEvent.EventTypeMask(rawValue: UInt64(Int(NSEvent.EventTypeMask([NSEvent.EventTypeMask.leftMouseDragged, NSEvent.EventTypeMask.leftMouseUp]).rawValue))))
        
        self.saveButton.isHidden = !self.initalStartup
        self.saveButton.isEnabled = !self.serverInput.cell!.title.isEmpty
        
        if let window = self.view.window, self.initalStartup
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
    
    override func mouseDown(with theEvent: NSEvent) {
        self.releaseServerField()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        self.saveButton.isEnabled = !self.serverInput.cell!.title.isEmpty
    }
    
    
    //MARK: IBActions
    @IBAction func saveClicked(_ sender: AnyObject)
    {
        self.saveSettings()
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.OK)
    }

    @IBAction func traceRequestsChanged(_ sender: NSButton)
    {
        self.releaseServerField()
        
    }
    @IBAction func loggingLevelSliderChanged(_ sender: NSSlider)
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
            let defaults = UserDefaults.standard
            
            defaults.setValue(self.traceRequestsButton.state.rawValue == 1, forKey: PredixMobilityConfiguration.traceLogsRequestsConfigKey)
            defaults.setValue(self.loggingLevelSlider.integerValue, forKey: PredixMobilityConfiguration.loggingLevelConfigKey)
            defaults.setValue(self.serverInput.cell!.title, forKey: PredixMobilityConfiguration.serverEndpointConfigKey)
            
            defaults.synchronize()
        }
    }
    
    // Initializes the UI with settings stored in NSDefaults.
    func loadSettings()
    {
        let defaults = UserDefaults.standard
        
        if let value = defaults.value(forKey: PredixMobilityConfiguration.traceLogsRequestsConfigKey), let boolValue = value as? Bool
        {
            self.traceRequestsButton.state = NSControl.StateValue(rawValue: boolValue ? 1 : 0)
        }
        else
        {
            self.traceRequestsButton.state = NSControl.StateValue(rawValue: PredixMobilityConfiguration.traceLogsAllRequestsDefault ? 1 : 0)
        }
        
        if let value = defaults.value(forKey: PredixMobilityConfiguration.loggingLevelConfigKey), let intValue = value as? Int
        {
            self.loggingLevelSlider.integerValue = intValue
        }
        else
        {
            self.loggingLevelSlider.integerValue = Int(PredixMobilityConfiguration.defaultLoggingLevel.rawValue)
        }
        
        self.setLoggingLevelDescription(self.loggingLevelSlider.integerValue)
        
        if let value = defaults.value(forKey: PredixMobilityConfiguration.serverEndpointConfigKey), let serverEndpoint = value as? String
        {
            self.serverInput.cell!.title = serverEndpoint
        }
    }
    
    //Translates logging levels to string descriptions.
    func setLoggingLevelDescription(_ levelInt: Int)
    {
        if let level = LoggerLevel(rawValue: levelInt)
        {
            self.loggingLevelLabel.cell!.title = level.description
        }
        else
        {
            self.loggingLevelLabel.cell!.title = ""
        }
    }

    //prompts the completion of text editing in the server hostname field when user interacts with a different part of the UI,
    //and when in initial popup mode, ensures the save button is enabled or disabled based on if the server hostname has been entered.
    func releaseServerField()
    {
        self.serverInput.window?.makeFirstResponder(nil)
        self.saveButton.isEnabled = !self.serverInput.cell!.title.isEmpty
    }

}
