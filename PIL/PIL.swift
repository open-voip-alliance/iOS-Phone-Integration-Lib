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
    internal lazy var platformIntegrator = { di.resolve(PlatformIntegrator.self)! }()
    
    let voipLib: VoIPLib = di.resolve(VoIPLib.self)!
    lazy var iOSCallKit = { di.resolve(IOSCallKit.self)! }()
    
    public lazy var actions = { di.resolve(CallActions.self)! }()
    public lazy var audio = { di.resolve(AudioManager.self)! }()
    public lazy var events = { di.resolve(EventsManager.self)! }()
    public lazy var calls = { di.resolve(Calls.self)! }()
    public lazy var iOS = { di.resolve(IOS.self)! }()
    
    var sessionState: CallSessionState {
        get {
            CallSessionState(activeCall: calls.activeCall, inactiveCall: calls.inactiveCall, audioState: audio.state)
        }
    }
    
    static public var isInitialized: Bool {
        get {
            shared != nil
        }
    }
    
    static public var shared: PIL?
    
    /// The user preferences for the PIL, when this value is updated it will trigger
    /// a full PIL restart and re-register.
    public var preferences = Preferences() {
        didSet {
            if isPreparedToStart && oldValue != preferences {
               start(forceInitialize: true, forceReregister: true)
            }
        }
    }
    
    /// The authentication details for the PIL, when this value is updated it will
    /// trigger a full re-register.
    public var auth: Auth? {
        didSet {
            if isPreparedToStart && oldValue != auth {
                start(forceInitialize: false, forceReregister: true)
            }
        }
    }
    
    init(applicationSetup: ApplicationSetup) {
        self.app = applicationSetup
        PIL.shared = self
        events.listen(delegate: platformIntegrator)
        self.iOS.startListeningForSystemNotifications()
    }
    
    /// Check if the PIL is currently configured to successfully register.
    /// Attempt to boot and register to see if user credentials are correct.
    /// - Parameter callback: Called when the registration check has been completed.
    public func performRegistrationCheck(callback: @escaping (Bool) -> Void) {
        guard let auth = auth else {
            callback(false)
            return
        }
        
        voipLibHelper.initialize(force: false)
        voipLibHelper.register(auth: auth, force: true, callback: callback)
    }
    
    /// Start the PIL, unless the force options are provided, the method will not restart or re-register.
    /// - Parameters:
    ///   - forceInitialize: a Bool to determine if the voipLib will restart.
    ///   - forceReregister: a Bool to determine the voipLib will re-register.
    ///   - completion:  Called with param success when the PIL has been started.
    public func start(forceInitialize: Bool = false, forceReregister: Bool = false, completion: ((_ success: Bool) -> Void)? = nil) {
        guard let auth = auth else {
            print("There are not authentication details provided")
            return
        }

        pushKit.registerForVoipPushes()
        iOSCallKit.initialize()

        voipLibHelper.initialize(force: forceInitialize)
        voipLibHelper.register(auth: auth, force: forceReregister) { success in
            completion?(success)
        }
    }
    
    /// Stop the PIL, this will remove all authentication credentials from memory and destroy the underlying voip lib. This will not destroy the PIL.
    ///
    /// This should be called when a user logs-out (or similar action).
    public func stop() {
        auth = nil
        voipLib.destroy()
    }
    
    /// Place a call to the given number.
    /// This will boot the lib if it is not already booted.
    /// - Parameter number: the String number to call.
    public func call(number: String) {
        if calls.isInCall {
            return
        }
        
        start { _ in
            self.iOSCallKit.startCall(number: number)
        }
    }
    
    internal func writeLog(_ message: String, level: LogLevel = .info) {
        app.logDelegate?.onLogReceived(message: "PhoneIntegrationLib: \(message)", level: level)
    }
    
    /// Check whether the PIL has been initialized and the authentication details are set.
    private var isPreparedToStart: Bool {
        auth != nil && voipLib.isInitialized
    }
    
    /// Currently this just defers to ``isPreparedToStart`` as they have the same conditions but this may change in the future.
    internal var isStarted: Bool {
        isPreparedToStart
    }
}

internal func log(_ message: String, level: LogLevel = .info) {
    if let pil = PIL.shared {
        pil.writeLog(message, level: level)
    }
}

public enum PILError: Error {
    case alreadyInitialized
}
