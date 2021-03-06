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
    
    private let defaults = UserDefaults.standard
    
    private weak var pil: PIL?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let applicationSetup = ApplicationSetup(
            middleware: VoIPGRIDMiddleware(),
            requestCallUi: {
              
                if let nav = self.window?.rootViewController as? UITabBarController {
                    nav.performSegue(withIdentifier: "LaunchCallSegue", sender: nav)
                }
            }
        )
        
        pil = startIOSPIL(applicationSetup: applicationSetup)

        pil?.auth = Auth(
            username: self.userDefault(key: "username"),
            password: self.userDefault(key: "password"),
            domain: self.userDefault(key: "domain"),
            port: Int(self.userDefault(key: "port")) ?? 0,
            secure: self.defaults.bool(forKey: "encryption")
        )
        
        pil?.start {
            
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        pil?.iOS.applicationWillEnterForeground()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        pil?.iOS.applicationDidEnterBackground()
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers

}

