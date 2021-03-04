//
//  PIL.swift
//  PIL
//
//  Created by Chris Kontos on 04/12/2020.
//

import Foundation
import iOSPhoneLib
import CallKit

public class PIL: RegistrationStateDelegate {

    public let actions = di.resolve(CallActions.self)!
    public let audio = di.resolve(AudioManager.self)!
    public let events = di.resolve(EventsManager.self)!
    public let calls = di.resolve(Calls.self)!
    public let callFactory = di.resolve(PILCallFactory.self)!
    
    static public var shared: PIL?
    
    lazy var phoneLib: PhoneLib = PhoneLib.shared
    public var isRegistered: Bool {
        get{
          return PhoneLib.shared.isRegistered
        }
    }
    
    var callKitProviderDelegate: CallKitDelegate!
    var firstTransferCall: PILCall?
    var secondTransferCall: PILCall?
    
    public var call: PILCall?
    let pushKitManager: PushKitManager
    
    //private var onRegister: ((Bool) -> ()) //wip
    private var incomingUuid: UUID?
    private var onIncomingCall: ((PILCall) -> ())?
    
    public var auth: Auth? = nil {
        didSet {
            if (auth?.isValid != true) {
                print("Attempting to set an invalid auth object")
                auth = nil
            }
        }
    }
    
    var hasActiveCall: Bool {
        get {
            self.call != nil
        }
    }
    
    var isMicrophoneMuted: Bool {
        get {
            self.phoneLib.isMicrophoneMuted
        }
    }
    
    init(applicationSetup: ApplicationSetup) {
        pushKitManager = PushKitManager(middleware: applicationSetup.middleware!)
        callKitProviderDelegate = CallKitDelegate(pil: self)
        PIL.shared = self
    }
    
    /// Start the PIL.
    /// Unless an Authentication object is provided, the method will use the pil.auth property.
    /// Unless the force options are provided, the method will not restart or re-register.
    public func start(authentication:Auth? = nil,
               forceInitialize: Bool = false,
               forceReregister: Bool = false,
               completion: ((Bool) -> ())) {
        
        if authentication != nil {
            auth = authentication
        }
        
        guard auth != nil else {
            completion(false)
            return
        } //TODO: throw NoAuthenticationCredentialsException()

        if (forceInitialize) {
            unregister()
        }

        if (!forceReregister && isRegistered){
            print("The user was already registered and will not force re-registration.")
            completion(true)
        }
        
        //phoneLib.initialize(config: <#T##Config#>) //wip create the Config file
//        config.callDelegate = self
        
        
        register { success in
            if !success {
                print("Unable to register.")
                completion(false)
            }
            
            print("The user has been registered successfully.")
            completion(true)
        }
    }
    
    func register(onRegister: ((Bool) -> ())) {
        //PhoneLib.shared.registrationDelegate = self

//        guard let username = auth?.username,
//              let password = auth?.password,
//              let domain = auth?.domain,
//              let port = auth?.port,
//              let secure = auth?.secure
//        else {
//            onRegister(false)
//            return
//        }
//        
//        print("Registering with \(username) + \(password) encrypted:\(secure) at \(domain):\(port)")
//        let success = phoneLib.register
//
//        if !success() {
//            print("Failed to register.")
//        }
//        onRegister(success())
    }

    public func unregister() {
        phoneLib.unregister {
            print("Unregistered.")
        }
    }
    
    public func registerForVoIPPushes(){
        pushKitManager.registerForVoIPPushes()
    }
    
    func acceptIncomingCall(callback: @escaping () -> ()) {
//        self.onIncomingCall = { call in
//            _ = self.phoneLib.acceptCall(for: call.session)
//            callback()
//        }
//
//        if let call = self.call {
//            print("We have found the call already and can accept it.")
//            self.onIncomingCall?(call)
//            self.onIncomingCall = nil
//            return
//        }
//
//        print("We have no call yet, so we will queue to accept as soon as possible.")
    }
    
    func prepareForIncomingCall(uuid: UUID) {
        self.incomingUuid = uuid
    }
    
    func findCallByUuid(uuid: UUID) -> PILCall? { //TODO: if this will not be called from here move it to CallKitDelegate
        if call?.uuid == uuid {
            return call
        }
        return nil
    }
    
    
// MARK: - RegistrationStateDelegate
    public func didChangeRegisterState(_ state: SipRegistrationStatus, message: String?) {
        print("Registration state: \(String(reflecting: state)) with message \(String(describing: message))")
        
        if state == .failed {
            if let uuid = incomingUuid {
                print("Reporting call ended with uuid: \(uuid)")
                callKitProviderDelegate.provider.reportCall(with: uuid, endedAt: Date(), reason: CXCallEndedReason.failed)
            }
        }
    }
}

// MARK: - SessionDelegate
extension PIL: CallDelegate {

    public func didReceive(incomingSession: Session) {
        print("Incoming session didReceive")

        guard let uuid = self.incomingUuid else { //wip check if the session has the same sesionid with this
            print("No incoming uuid set, cannot accept incoming call")
            return
        }

        self.incomingUuid = nil

        VoIPPushHandler.incomingCallConfirmed = true

        DispatchQueue.main.async {
            print("Incoming call block invoked, routing through CallKit.")
            //wip self.call = PILCall(session: incomingSession, direction: CallDirection.inbound, uuid: uuid)
            self.call = self.callFactory.make(session: incomingSession)
            
            self.callKitProviderDelegate.reportIncomingCall()
            self.onIncomingCall?(self.call!)
            self.onIncomingCall = nil
        }
    }

    public func outgoingDidInitialize(session: Session) {
        print("On outgoingDidInitialize.")
            
//        self.call = PILCall(session: session, direction: CallDirection.outbound)
        self.call = callFactory.make(session: session)
        guard let call = self.call else {
            print("Unable to find call setup...")
            return
        }

        print("Have call with uuid \(call.uuid)")

        let controller = CXCallController()
        let handle = CXHandle(type: .phoneNumber, value: call.session.remoteNumber)
        let startCallAction = CXStartCallAction(call: call.uuid, handle: handle)

        let transaction = CXTransaction(action: startCallAction)
        controller.request(transaction) { error in
            if error != nil {
                print("Error on outgoing call \(String(describing: error?.localizedDescription))")
            } else {
                print("Setup of outgoing call.")
            }
        }
    }

    public func sessionUpdated(_ session: Session, message: String) {
        print("sessionUpdated: \(message)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call-update"), object: nil)
    }

    public func sessionConnected(_ session: Session) {
        print("sessionConnected")
    }

    public func sessionEnded(_ session: Session) {
        print("Session has ended with session.uuid: \(session.sessionId).")
        
        if session.sessionId == firstTransferCall?.session.sessionId {
            call = firstTransferCall
            print("First Transfer Call is ending.")
        } else if session.sessionId == secondTransferCall?.session.sessionId {
            call = secondTransferCall
            print("Second Transfer Call is ending.")
        }
        
        if self.call == nil {
            print("Session ended with nil call object, not reporting call ended to callKitDelegate.")
            return
        }
            
        print("Ending call with sessionId:\(call!.session.sessionId) because session ended with uuid:\(session.sessionId)")
        callKitProviderDelegate.provider.reportCall(with: call!.uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call-update"), object: nil)
        self.call = nil
    }

    public func sessionReleased(_ session: Session) {
        print("Session released.")
        
        if firstTransferCall != nil && firstTransferCall?.session.sessionId != session.sessionId {
            print("Transfer's second call was cancelled or declined.")
            if let uuid = call?.uuid {
                callKitProviderDelegate.provider.reportCall(with: uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
            }
            self.call = firstTransferCall
        }
        
        if let call = self.call {
            if call.session.state == .released {
                print("Setting call with UUID: \(call.uuid) to nil because its session has been released.")
                callKitProviderDelegate.provider.reportCall(with: call.uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
                self.call = nil
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call-update"), object: nil)
    }

    public func error(session: Session, message: String) {
        print("Error: \(message) for call with sessionUUID: \(session.sessionId)")
    }
}
