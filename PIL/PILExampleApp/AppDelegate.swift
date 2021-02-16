//
//  AppDelegate.swift
//  PILExampleApp
//
//  Created by Chris Kontos on 08/01/2021.
//

import UIKit
import PIL

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let applicationSetup = ApplicationSetup(middleware: VoIPGRIDMiddleware())
        
        let pil = startIOSPIL(applicationSetup: applicationSetup)

        return true
    }

}

