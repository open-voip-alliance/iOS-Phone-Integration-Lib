//
//  PIL.swift
//  PIL
//
//  Created by Chris Kontos on 04/12/2020.
//

import Foundation
import PhoneLib
import CallKit

public class PIL: RegistrationStateDelegate {

    static public let shared = PIL()
    
    lazy var phoneLib: PhoneLib = PhoneLib.shared
    
    var callKitProviderDelegate: CallKitDelegate!
    var call: Call?
    var firstTransferCall: Call?
    var secondTransferCall: Call?
    
    private var onRegister: ((Error?) -> ())?
    private var incomingUuid: UUID?
    private var onIncomingCall: ((Call) -> ())?
    
    var auth: Auth? = nil {
        didSet {
            if (auth?.isValid != true) {
                print("Attempting to set an invalid auth object") //, LogLevel.ERROR) //wip add logging system
                auth = nil
                return
            }

            start(forceInitialize: false, forceReregister: true)
        }
    }
    
    init() {
        callKitProviderDelegate = CallKitDelegate(pil: self)
//        phoneLib.sessionDelegate = self //wip implement sessionDelegate methods
        phoneLib.setAudioCodecs([Codec.OPUS])
    }
    
    /// Start the PIL, unless the force options are provided, the method will not restart or re-register.
    func start(forceInitialize: Bool = false,
               forceReregister: Bool = false,
               completion: (() -> Unit)? = nil) {
        
        guard let auth = auth else {return} //wip implement throw NoAuthenticationCredentialsException()
        
        if (!auth.isValid) {return}//wip throw NoAuthenticationCredentialsException()

//        if (forceInitialize) { //wip implement destroy on phoneLib and then in PIL
//            phoneLib.destroy()
//        }
        
        if (!forceReregister && phoneLib.registrationStatus == .registered){
            print("The user was already registered and will not force re-registration.")
            return
        }
        
        register { error in
            if error != nil {
                print("Unable to register.")
                return
            }

            print("The user has been registered successfully.")
        }
    }
    
    func register(onRegister: ((Error?) -> ())? = nil) { //wip make sure it returns error correclty
        PhoneLib.shared.registrationDelegate = self

        guard let username = auth?.username,
              let password = auth?.password,
              let domain = auth?.domain,
              let port = auth?.port,
              let secure = auth?.secure
        else {
            return
        }

        self.onRegister = onRegister
        
        print("Registering with \(username) + \(password) encrypted:\(secure) at \(domain):\(port)")
        let success = phoneLib.register(domain: domain, port: port, username: username, password: password, encrypted: secure)

        if !success {
            print("Failed to register.")
        }
    }

    func unregister() {
        phoneLib.unregister {
            print("Unregistered.")
        }
    }
    
    
// MARK: - RegistrationStateDelegate
    public func didChangeRegisterState(_ state: SipRegistrationStatus, message: String?) {
        print("Reg state: \(String(reflecting: state)) with message \(String(describing: message))")

        if state == .registered {
            onRegister?(nil)
            onRegister = nil
        }

        if state == .failed {
            onRegister?(RegistrationError.failed)
            onRegister = nil
            if let uuid = incomingUuid {
                print("Reporting call ended with uuid: \(uuid)")
                callKitProviderDelegate.provider.reportCall(with: uuid, endedAt: Date(), reason: CXCallEndedReason.failed)
            }
        }
    }
}

// MARK: - SessionDelegate
extension PIL: SessionDelegate {

    public func didReceive(incomingSession: Session) {
        print("Incoming session didReceive")

        guard let uuid = self.incomingUuid else {
            print("No incoming uuid set, cannot accept incoming call")
            return
        }

        self.incomingUuid = nil

        VoIPPushHandler.incomingCallConfirmed = true

        DispatchQueue.main.async {
            print("Incoming call block invoked, routing through CallKit.")
            self.call = Call(session: incomingSession, direction: Direction.inbound, uuid: uuid)
            self.callKitProviderDelegate.reportIncomingCall()
            self.onIncomingCall?(self.call!)
            self.onIncomingCall = nil
        }
    }

    public func outgoingDidInitialize(session: Session) {
        print("On outgoingDidInitialize.")
        
        self.call = Call(session: session, direction: Direction.outbound)
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
