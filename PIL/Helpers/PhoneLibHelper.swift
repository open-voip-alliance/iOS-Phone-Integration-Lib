//
//  PhoneLibHelper.swift
//  PIL
//
//  Created by Jeremy Norman on 01/03/2021.
//

import Foundation
import iOSVoIPLib

class PhoneLibHelper {

    private let phoneLib: PhoneLib
    private let pil: PIL
    private let callManager: CallManager
    
    init(phoneLib: PhoneLib, pil: PIL, callManager: CallManager) {
        self.phoneLib = phoneLib
        self.pil = pil
        self.callManager = callManager
    }
    
    internal func initialize(force: Bool) {
        if phoneLib.isInitialized && !force {
            pil.writeLog("The VoIP library is already initialized, skipping init.")
        }
        
        guard let auth = pil.auth else {
            pil.writeLog("There are no authentication credentials, not registering.")
            return
        }
        
        phoneLib.initialize(
            config: createConfig(auth: auth)
        )
    }

    internal func register(auth: Auth, force: Bool = false, callback: @escaping (Bool) -> Void) {
        guard let auth = pil.auth else {
            pil.writeLog("There are no authentication credentials, not registering.")
            return
        }
        
        phoneLib.swapConfig(config: createConfig(auth: auth))
        
        if phoneLib.isRegistered && !force {
            pil.writeLog("We are already registered!")
            callback(true)
            return
        }
        
        pil.writeLog("Attempting registration...")
        
        phoneLib.register { state in
            self.pil.writeLog("Registration response: \(state)")
            
            if state == .registered {
                self.pil.writeLog("Registration was successful!")
                callback(true)
            }
            else if state == .failed {
                self.pil.writeLog("Registration failed.")
                callback(false)
            }
        }
    }
    
    private func createConfig(auth: Auth) -> iOSVoIPLib.Config {
        iOSVoIPLib.Config(
            auth: iOSVoIPLib.Auth(name: auth.username, password: auth.password, domain: auth.domain, port: auth.port),
            callDelegate: callManager
        )
    }
}
