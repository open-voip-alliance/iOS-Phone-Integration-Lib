//
//  PIL.swift
//  PIL
//
//  Created by Chris Kontos on 04/12/2020.
//

import Foundation
import iOSVoIPLib
import CallKit

public class PIL {

    let app: ApplicationSetup
    
    private let callFactory = di.resolve(PILCallFactory.self)!
    private lazy var pushKit: PushKitDelegate = { PushKitDelegate(middleware: app.middleware!) }()
    private lazy var voipLibHelper = { di.resolve(VoIPLibHelper.self)! }()
    
    let voipLib: VoIPLib = di.resolve(VoIPLib.self)!
    lazy var iOSCallKit = { di.resolve(IOSCallKit.self)! }()
    
    public lazy var actions = { di.resolve(CallActions.self)! }()
    public lazy var audio = { di.resolve(AudioManager.self)! }()
    public lazy var events = { di.resolve(EventsManager.self)! }()
    public lazy var calls = { di.resolve(Calls.self)! }()
    public lazy var iOS = { di.resolve(IOS.self)! }()
    
    static public var shared: PIL?
    
    public var preferences = Preferences() {
        didSet {
            if isPreparedToStart {
                self.start(forceInitialize: true, forceReregister: true)
            }
        }
    }
    
    public var auth: Auth? {
        didSet {
            if isPreparedToStart {
                self.start(forceInitialize: false, forceReregister: true)
            }
        }
    }
    
    init(applicationSetup: ApplicationSetup) {
        self.app = applicationSetup
        PIL.shared = self
        self.iOS.startListeningForSystemNotifications()
    }
    
    /**
      Quickly check if the PIL is currently configured to successfully register.
     
     - Parameter callback: Called when the registration check has been completed.
     */
    public func performRegistrationCheck(callback: @escaping (Bool) -> Void) {
        guard let auth = self.auth else {
            callback(false)
            return
        }
        
        voipLibHelper.initialize(force: false)
        voipLibHelper.register(auth: auth, callback: callback)
    }
    
    public func start(forceInitialize: Bool = false, forceReregister: Bool = false, completion: (() -> Void)? = nil) {
        guard let auth = self.auth else {
            print("There are not authentication details provided")
            return
        }

        pushKit.registerForVoipPushes()
        iOSCallKit.initialize()
        
        if (forceInitialize) {
            voipLib.destroy()
        }

        voipLibHelper.initialize(force: forceInitialize)
        voipLibHelper.register(auth: auth, force: forceReregister) { _ in
            completion?()
        }
    }
    
    public func call(number: String) {
        if calls.isInCall {
            return
        }
        
        start {
            self.iOSCallKit.startCall(number: number)
        }
    }
    
    internal func writeLog(_ message: String) {
        print("PhoneIntegrationLib:" + message)
    }
    
    private var isPreparedToStart: Bool {
        get {
            auth != nil && voipLib.isInitialized
        }
    }
}
