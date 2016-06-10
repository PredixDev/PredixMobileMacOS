//
//  AppDelegate.swift
//  PredixMobileMacOS
//
//  Created by Johns, Andy (GE Corporate) on 6/7/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Cocoa
import PredixMobileSDK

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // logging our current running environment
        PGSDKLogger.debug("Started app: \(aNotification.userInfo)")
        
        let versionInfo = PredixMobilityConfiguration.getVersionInfo()
        
        let processInfo = NSProcessInfo.processInfo()
        
        PGSDKLogger.info("Running Environment:\n     locale: \(versionInfo[VersionInfoKeys.Locale] ?? "")\n     device model:\(versionInfo[VersionInfoKeys.DeviceModel] ?? "")\n     device system name:\(versionInfo[VersionInfoKeys.DeviceOS] ?? "")\n     device system version:\(versionInfo[VersionInfoKeys.DeviceOSVersion] ?? "")\n     macOS Version/Build: \(processInfo.operatingSystemVersionString)\n     app bundle id: \(versionInfo[VersionInfoKeys.ApplicationBundleId] ?? "")\n     app version: \(versionInfo[VersionInfoKeys.ApplicationVersion] ?? "")\n     app build version: \(versionInfo[VersionInfoKeys.ApplicationBuildVersion] ?? "")\n     \(PredixMobilityConfiguration.versionInfo)")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

}

