//
//  SettingsViewController.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 12/02/2021.
//

import Foundation
import QuickTableViewController
import PIL

final class SettingsViewController: QuickTableViewController {

    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        tableContents = [

            Section(title: "Authentication", rows: [
                NavigationRow(text: "Username", detailText: .subtitle(userDefault(key: "username")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Username", key: "username") }),
                NavigationRow(text: "Password", detailText: .subtitle(userDefault(key: "password")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Password", key: "password") }),
                NavigationRow(text: "Domain", detailText: .subtitle(userDefault(key: "domain")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Domain", key: "domain") }),
                NavigationRow(text: "Port", detailText: .subtitle(userDefault(key: "port")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Port", key: "port") }),
                TapActionRow(text: "Test Authentication", action: { row in
                    let pil = PIL.shared!
                    pil.auth = Auth(
                        username: self.userDefault(key: "username"),
                        password: self.userDefault(key: "password"),
                        domain: self.userDefault(key: "domain"),
                        port: Int(self.userDefault(key: "port")) ?? 0,
                        secure: self.defaults.bool(forKey: "encryption")
                    )
                    pil.performRegistrationCheck { (success) in
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Authentication Test", message: success ? "Authenticated successfully!" : "Authentication failed :(", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                })
            ]),

            Section(title: "VoIPGRID", rows: [
                NavigationRow(text: "Username", detailText: .subtitle(userDefault(key: "voipgrid_username")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Username", key: "voipgrid_username") }),
                NavigationRow(text: "Password", detailText: .subtitle(userDefault(key: "voipgrid_password")), icon: .named("gear"), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Password", key: "voipgrid_password") }),
                SwitchRow(text: "VoIP Account Encryption", switchValue: self.defaults.bool(forKey: "VoIP Account Encryption"), customization: { cell,row in
                        let middleware = VoIPGRIDMiddleware()
                        cell.isUserInteractionEnabled = middleware.isVoipgridTokenValid
                        if middleware.isVoipgridTokenValid == false {
                            if let switchRow = row as? SwitchRowCompatible {
                                switchRow.switchValue = false
                            }
                        }
                    }, action: { row in
                        if let switchRow = row as? SwitchRowCompatible {
                            self.attemptVoIPAccountEncryptionChangeTo(encryption: switchRow.switchValue)
                        }
                    }),
                NavigationRow(text: "VoIPGRID Token", detailText: .subtitle(userDefault(key: "voipgrid_api_token")), action: nil),
                NavigationRow(text: "Push Kit Token", detailText: .subtitle(userDefault(key: "push_kit_token")), action: nil),
                NavigationRow(text: "Middleware", detailText: .subtitle(defaults.bool(forKey: "middleware_is_registered") ? "Registered" : "Not Registered"), action: nil),
                TapActionRow(text: "Register with Middleware", action: { _ in self.registerMiddleware() }),
                TapActionRow(text: "Unregister with Middleware", action: { _ in self.unregisterMiddleware() }),
            ]),
            
            Section(title: "Preferences", rows: [
                SwitchRow(text: "Encryption", switchValue: self.defaults.bool(forKey: "encryption"), action: { row in
                    if let switchRow = row as? SwitchRowCompatible {
                        self.defaults.set(switchRow.switchValue, forKey: "encryption")
                    }
                }),
                SwitchRow(text: "Use Application Ringtone", switchValue: self.defaults.bool(forKey: "use_application_ringtone"), action: { row in
                    if let switchRow = row as? SwitchRowCompatible {
                        self.defaults.set(switchRow.switchValue, forKey: "use_application_ringtone")
                    }
                }),
            ])
        ]
    }
    
    private func promptUserWithTextField(row: Row, title: String, key: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            self.defaults.set(textField.text, forKey: key)
            
            if key.contains("voipgrid") {
                self.attemptVoipgridLogin()
            } else {
                self.viewDidLoad()
            }
        }
        alert.addTextField { (textField) in
            textField.text = self.userDefault(key: key)
        }
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
    
    private func attemptVoipgridLogin() {
        let voipgridLogin = VoIPGRIDLogin()
        voipgridLogin.login { apiToken in
            guard let apiToken = apiToken else {
                self.defaults.removeObject(forKey: "voipgrid_api_token")
                self.unregisterMiddleware()
                self.viewDidLoad()
                return
            }
            
            self.defaults.set(apiToken, forKey: "voipgrid_api_token")
            self.viewDidLoad()
        }
    }
    
    private func attemptVoIPAccountEncryptionChangeTo(encryption: Bool) {
        let middleware = VoIPGRIDMiddleware()
        middleware.setVoIPAccountEncryption(encryption: encryption, completion: { _ in
            self.viewDidLoad()
        })
    }
    
    private func registerMiddleware() {
        let middleware = VoIPGRIDMiddleware()
        middleware.register { success in
            if success {
                self.defaults.set(true, forKey: "middleware_is_registered")
            }
            self.viewDidLoad()
        }
    }
    
    private func unregisterMiddleware() {
        let middleware = VoIPGRIDMiddleware()
        middleware.unregister { success in
            if success {
                self.defaults.set(false, forKey: "middleware_is_registered")
            }
            self.viewDidLoad()
        }
    }

    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    }
}

