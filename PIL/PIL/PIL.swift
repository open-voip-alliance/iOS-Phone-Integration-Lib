//
//  PIL.swift
//  PIL
//
//  Created by Chris Kontos on 04/12/2020.
//

import Foundation
import iOSPhoneLib
import CallKit

public class PIL {

    let app: ApplicationSetup
    
    private let callFactory = di.resolve(PILCallFactory.self)!
    private lazy var pushKit: PushKitDelegate = { PushKitDelegate(middleware: app.middleware!) }()
    private lazy var phoneLibHelper = { di.resolve(PhoneLibHelper.self)! }()
    
    let phoneLib: PhoneLib = di.resolve(PhoneLib.self)!
    lazy var iOSCallKit = { di.resolve(IOSCallKit.self)! }()
    
    public lazy var actions = { di.resolve(CallActions.self)! }()
    public let audio = di.resolve(AudioManager.self)!
    public let events = di.resolve(EventsManager.self)!
    public lazy var calls = { di.resolve(Calls.self)! }()
    
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
        
        phoneLibHelper.initialize(force: false)
        phoneLibHelper.register(auth: auth, callback: callback)
    }
    
    public func start(forceInitialize: Bool = false, forceReregister: Bool = false, completion: (() -> Void)? = nil) {
        guard let auth = self.auth else {
            fatalError("There are not authentication details provided")
        }

        pushKit.registerForVoipPushes()
        iOSCallKit.initialize()
        
        if (forceInitialize) {
            phoneLib.destroy()
        }

        phoneLibHelper.initialize(force: forceInitialize)
        phoneLibHelper.register(auth: auth, force: forceReregister) { _ in
            completion?()
        }
    }
    
    public func call(number: String) {
        start {
            self.iOSCallKit.startCall(number: number)
        }
    }
    
    internal func writeLog(_ message: String) {
        print(message)
    }
    
    private var isPreparedToStart: Bool {
        get {
            auth != nil && phoneLib.isInitialized
        }
    }

}
