//
//  CallManager.swift
//  PIL
//
//  Created by Jeremy Norman on 04/03/2021.
//

import Foundation
import iOSPhoneLib
import CallKit
class CallManager: CallDelegate {

    private let pil: PIL
    
    internal var call: Call? = nil
    internal var transferSession: AttendedTransferSession? = nil
    
    var isInCall: Bool {
        get {
            call != nil
        }
    }
    
    init(pil: PIL) {
        self.pil = pil
    }
        
    public func didReceive(incomingCall: Call) {
        if !isInCall {
            self.call = incomingCall
            pil.events.broadcast(event: .incomingCallReceived, call: incomingCall)
            callKitUpdateCurrentCall(incomingCall)
        }
    }

    public func outgoingDidInitialize(call: Call) {
        if !isInCall {
            self.call = call
            pil.iOSCallKit.provider.reportOutgoingCall(with: pil.iOSCallKit.uuid!, startedConnectingAt: Date())
            pil.events.broadcast(event: .outgoingCallStarted, call: call)
        }
    }

    public func callUpdated(_ call: Call, message: String) {
        pil.events.broadcast(event: .callUpdated, call: call)
        callKitUpdateCurrentCall(call)
    }

    public func callConnected(_ call: Call) {
        callKitUpdateCurrentCall(call)
        pil.app.requestCallUi()
        pil.events.broadcast(event: .callConnected, call: call)
    }

    public func callEnded(_ session: Call) {
        if !pil.calls.isInTranfer {
            pil.iOSCallKit.provider.reportCall(with: pil.iOSCallKit.uuid!, endedAt: Date(), reason: .remoteEnded)
            self.call = nil
        }
        
        pil.events.broadcast(event: .callEnded, call: call)
        transferSession = nil
    }

    public func callReleased(_ call: Call) {
        callEnded(call)
    }

    public func error(call: Call, message: String) {
        callEnded(call)
        pil.writeLog("ERROR: \(message)")
    }
    
    private func callKitUpdateCurrentCall(_ call: Call) {
        print("TEST123: CALL KIT UPDATE NOW:")
        let update = CXCallUpdate()
        update.hasVideo = false
        update.localizedCallerName = call.remoteNumber
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = true
        update.supportsDTMF = true
        
        pil.iOSCallKit.provider.reportCall(with: pil.iOSCallKit.uuid!, updated: update)
    }
}
