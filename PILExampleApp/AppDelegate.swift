//
//  AppDelegate.swift
//  PILExampleApp
//
//  Created by Chris Kontos on 08/01/2021.
//

import UIKit
import PIL

@main
class AppDelegate: UIResponder, UIApplicationDelegate, LogDelegate {
    

    var window: UIWindow?
    
    private let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let applicationSetup = ApplicationSetup(
            middleware: VoIPGRIDMiddleware(),
            requestCallUi: {
                if let nav = self.window?.rootViewController as? UITabBarController {
                    nav.performSegue(withIdentifier: "LaunchCallSegue", sender: nav)
                }
            },
            logDelegate: self
        )
        
        _ = startIOSPIL(
            applicationSetup: applicationSetup,
            auth: Auth(
                username: self.userDefault(key: "username"),
                password: self.userDefault(key: "password"),
                domain: self.userDefault(key: "domain"),
                port: Int(self.userDefault(key: "port")) ?? 0,
                secure: self.defaults.bool(forKey: "encryption")
            ),
            autoStart: true
        )
        
        return true
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers
    
    func onLogReceived(message: String, level: LogLevel) {
        print("\(String(describing: level)) \(message)")
    }
}

