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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // logging our current running environment
        Logger.debug("Started app: \(aNotification.userInfo)")
        
        if Logger.isInfoEnabled() {
            let versionInfo = PredixMobilityConfiguration.getVersionInfo()
            let processInfo = ProcessInfo.processInfo
            var runningEnvironment = "Running Environment:"
            runningEnvironment += "\n     locale: \(versionInfo[VersionInfoKeys.Locale] ?? "")"
            runningEnvironment += "\n     device model:\(versionInfo[VersionInfoKeys.DeviceModel] ?? "")"
            runningEnvironment += "\n     device system name:\(versionInfo[VersionInfoKeys.DeviceOS] ?? "")"
            runningEnvironment += "\n     device system version:\(versionInfo[VersionInfoKeys.DeviceOSVersion] ?? "")"
            runningEnvironment += "\n     macOS Version/Build: \(processInfo.operatingSystemVersionString)"
            runningEnvironment += "\n     app bundle id: \(versionInfo[VersionInfoKeys.ApplicationBundleId] ?? "")"
            runningEnvironment += "\n     app version: \(versionInfo[VersionInfoKeys.ApplicationVersion] ?? "")"
            runningEnvironment += "\n     app build version: \(versionInfo[VersionInfoKeys.ApplicationBuildVersion] ?? "")"
            runningEnvironment += "\n     \(PredixMobilityConfiguration.versionInfo)"
            
            Logger.info(runningEnvironment)
        }
        
        if let userNotification = aNotification.userInfo?[NSApplicationLaunchUserNotificationKey] as? NSUserNotification, let userInfo = userNotification.userInfo
        {
            Logger.debug("Startup with notification")
            Logger.trace("Startup notification info: \(userNotification.userInfo)")
            PredixMobilityManager.sharedInstance.applicationDelegates.application(application: NSApplication.shared(), didReceiveRemoteNotification: userInfo)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    
}

