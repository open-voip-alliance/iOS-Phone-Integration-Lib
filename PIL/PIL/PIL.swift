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

// MARK: - CallDelegate
extension PIL: CallDelegate {

    public func didReceive(incomingCall: Call) {
        print("Incoming session didReceive")

        guard let _ = self.incomingUuid else { //wip check if the call has the same callId with this
            print("No incoming uuid set, cannot accept incoming call")
            return
        }

        self.incomingUuid = nil

        VoIPPushHandler.incomingCallConfirmed = true

        DispatchQueue.main.async {
            print("Incoming call block invoked, routing through CallKit.")
            self.call = self.callFactory.make(phoneLibCall: incomingCall)
            
            self.callKitProviderDelegate.reportIncomingCall()
            self.onIncomingCall?(self.call!)
            self.onIncomingCall = nil
        }
    }

    public func outgoingDidInitialize(call: Call) {
        print("On outgoingDidInitialize.")
            
        self.call = callFactory.make(phoneLibCall: call)
        guard let call = self.call else {
            print("Unable to find call setup...")
            return
        }

        print("Have call with uuid \(call.uuid)")

        let controller = CXCallController()
        let handle = CXHandle(type: .phoneNumber, value: call.remoteNumber)
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

    public func callUpdated(_ call: Call, message: String) {
        print("callUpdated: \(message)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call-update"), object: nil)
    }

    public func callConnected(_ call: Call) {
        print("CallConnected")
    }

    public func callEnded(_ call: Call) {
        print("Call has ended with call.uuid: \(call.callId).")
        
        if call.callId == firstTransferCall?.phoneLibCall.callId {
            self.call = firstTransferCall
            print("First Transfer Call is ending.")
        } else if call.callId == secondTransferCall?.phoneLibCall.callId {
            self.call = secondTransferCall
            print("Second Transfer Call is ending.")
        }
        
        if self.call == nil {
            print("Call ended with nil call object, not reporting it to callKitDelegate.")
            return
        }
            
        print("Ending call with callId:\(self.call!.phoneLibCall.callId) because callEnded was called for uuid:\(call.callId)")
        callKitProviderDelegate.provider.reportCall(with: self.call!.uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call-update"), object: nil)
        self.call = nil
    }

    public func callReleased(_ call: Call) {
        print("Call released.")
        
        if firstTransferCall != nil && firstTransferCall?.phoneLibCall.callId != call.callId {
            print("Transfer's second call was cancelled or declined.")
            if let uuid = self.call?.uuid {
                callKitProviderDelegate.provider.reportCall(with: uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
            }
            self.call = firstTransferCall
        }
        
        if let pilCall = self.call {
            if pilCall.phoneLibCallState == .released {
                print("Setting call with UUID: \(pilCall.uuid) to nil because its session has been released.")
                callKitProviderDelegate.provider.reportCall(with: pilCall.uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
                self.call = nil
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call-update"), object: nil)
    }

    public func error(call: Call, message: String) {
        print("Error: \(message) for call with sessionUUID: \(call.callId)")
    }
}
