//
//  CallManager.swift
//  PIL
//
//  Created by Jeremy Norman on 04/03/2021.
//

import Foundation
import iOSVoIPLib
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
        
    public func incomingCallReceived(_ incomingCall: Call) {
        if !isInCall {
            self.call = incomingCall
            pil.events.broadcast(event: .incomingCallReceived)
            callKitUpdateCurrentCall(incomingCall)
        }
    }

    public func outgoingCallCreated(_ call: Call) {
        if !isInCall {
            self.call = call
            pil.iOSCallKit.provider.reportOutgoingCall(with: pil.iOSCallKit.uuid!, startedConnectingAt: Date())
            pil.events.broadcast(event: .outgoingCallStarted)
            pil.app.requestCallUi()
        }
    }

    public func callUpdated(_ call: Call, message: String) {
        pil.events.broadcast(event: .callUpdated)
        callKitUpdateCurrentCall(call)
    }

    public func callConnected(_ call: Call) {
        callKitUpdateCurrentCall(call)
        pil.events.broadcast(event: .callConnected)
        pil.app.requestCallUi()
    }

    public func callEnded(_ session: Call) {
        if !pil.calls.isInTranfer {
            pil.iOSCallKit.end()
            self.call = nil
        }
        
        pil.events.broadcast(event: .callEnded)
        transferSession = nil
    }
    
    public func error(_ call: Call, message: String) {
        callEnded(call)
        pil.writeLog("ERROR: \(message)")
    }
    
    private func callKitUpdateCurrentCall(_ call: Call) {
        let update = CXCallUpdate()
        update.hasVideo = false
        update.localizedCallerName = call.remoteNumber
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = true
        update.supportsDTMF = true
        
        if let uuid = pil.iOSCallKit.uuid {
            pil.iOSCallKit.provider.reportCall(with: uuid, updated: update)
        }
    }
}
