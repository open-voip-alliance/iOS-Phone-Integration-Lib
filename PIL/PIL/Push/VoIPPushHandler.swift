//
//  VoIPPushHandler.swift
//  PIL
//
//  Created by Chris Kontos on 23/12/2020.
//

import Foundation
import PushKit
import iOSPhoneLib
import CallKit

class VoIPPushHandler {

    private lazy var pil: PIL = PIL.shared!
    
    private let middleware: MiddlewareDelegate
    
    private lazy var callKit: CXProvider = {
        pil.callKitProviderDelegate.provider
    }()

    // This will be updated and set to TRUE when we have confirmation that we have received a call via SIP.
    // If we do not get this confirmation we can assume the call has failed and cancel the ringing.
    // However, it must always be set to false when a new call is coming in.
    static var incomingCallConfirmed = false
    
    private struct PayloadLookup {
        static let uniqueKey = "unique_key"
        static let phoneNumber = "phonenumber"
        static let responseUrl = "response_api"
        static let callerId = "caller_id"
    }
    
    init(middleware: MiddlewareDelegate) {
        self.middleware = middleware
    }


    func handle(payload: PKPushPayload, completion: @escaping () -> ()) {
        VoIPPushHandler.self.incomingCallConfirmed = false

        let payload = payload.dictionaryPayload as NSDictionary
        guard let uuid = getUUIDFrom(payload: payload) else {
            print("Handling call failed due to invalid UUID.")
            return
        }

        self.pil.prepareForIncomingCall(uuid: uuid)

        callKit.reportNewIncomingCall(with: uuid, update: createCxCallUpdate(from: payload)) { error in
            if (error != nil) {
                print("Failed to create incoming call: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.rejectSecondIncomingCall(with: payload)

            completion()
        }

        establishConnection(for: payload)
    }

    func rejectSecondIncomingCall(with payload: NSDictionary) {
        if self.pil.hasActiveCall {
            respond(with: payload, available: false)
            
            guard let uuid = getUUIDFrom(payload: payload) else {
                print("Rejecting call failed due to invalid UUID.")
                return
            }
            self.rejectCall(uuid: uuid, description: "Rejecting call as there is already one in progress")
        }
    }

    /**
        Attempts to asynchronously create a VoIP connection, if this fails we must report the call as failed to hide
        the now ringing UI.
    */
    func establishConnection(for payload: NSDictionary) {
        if pil.hasActiveCall {
            return
        }

        guard let uuid = getUUIDFrom(payload: payload) else {
            print("Failed to establish connection due to invalid UUID.")
            return
        }

        pil.register { success in
            if !success {
                self.rejectCall(uuid: uuid, description: "Failed to register with SIP, rejecting the call...")
                return
            }

            self.respond(with: payload, available: true) { error in
                if (error != nil) {
                    self.rejectCall(uuid: uuid, description: "Unable to contact middleware")
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if (!VoIPPushHandler.self.incomingCallConfirmed) {
                        self.rejectCall(uuid: uuid, description: "Unable to get call confirmation...")
                    }
                }
            }
        }
    }
    
    func getUUIDFrom(payload: NSDictionary) -> UUID? {
        guard let uuid = NSUUID.uuidFixer(uuidString: payload[PayloadLookup.uniqueKey] as! String) as UUID? else {
           return nil
        }
        return uuid
    }

    /**
        Respond to the middleware, this will determine if we receive the call or not.
    */
    private func respond(with payload: NSDictionary, available: Bool, completion: ((Error?) -> ())? = nil) {
        if (completion == nil) {
            middleware.respond(payload: payload, available: available)
        } else {
            middleware.respond(payload: payload, available: available)
        }
    }

    /**
        To reject a call we have to momentarily show the UI and then immediately report it as failed. The user will still see/hear
        the incoming call briefly.
     */
    private func rejectCall(uuid: UUID, reason: CXCallEndedReason = CXCallEndedReason.failed, description: String) {
        print(description)
        self.callKit.reportCall(with: uuid, endedAt: nil, reason: reason)
    }

    /**
        Creates the CXCallUpdate object with the relevant information from the payload.
    */
    private func createCxCallUpdate(from payload: NSDictionary) -> CXCallUpdate {
        let callerId = payload[PayloadLookup.callerId] as? String
        let phoneNumber = payload[PayloadLookup.phoneNumber] as? String
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .phoneNumber, value: phoneNumber ?? "")
        callUpdate.localizedCallerName = callerId ?? phoneNumber
        return callUpdate
    }
}

