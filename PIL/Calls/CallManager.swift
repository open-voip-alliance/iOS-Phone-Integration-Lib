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
    
    internal var voipLibCall: VoIPLibCall? = nil
    internal var transferSession: AttendedTransferSession? = nil
    
    var isInCall: Bool {
        get {
            voipLibCall != nil
        }
    }
    
    init(pil: PIL) {
        self.pil = pil
    }
        
    public func incomingCallReceived(_ incomingCall: VoIPLibCall) {
        if !isInCall {
            pil.writeLog("Setting up the incoming call")
            self.voipLibCall = incomingCall
            pil.events.broadcast(event: .incomingCallReceived)
            callKitUpdateCurrentCall(incomingCall)
        } else {
            pil.writeLog("Detecting incoming call received while already in call so not doing anything")
        }
    }

    public func outgoingCallCreated(_ call: VoIPLibCall) {
        pil.writeLog("On outgoingCallCreated")
        if !isInCall {
            pil.writeLog("Setting up the outgoing call")
            self.voipLibCall = call
            pil.iOSCallKit.reportOutgoingCallConnecting()
            pil.events.broadcast(event: .outgoingCallStarted)
            pil.app.requestCallUi()
        } else {
            guard self.pil.calls.isInTranfer else {
                pil.writeLog("Detected outgoing call creation while already in call so not doing anything")
                return
            }
            pil.writeLog("Setting up the second outgoing call for transfer")
            pil.events.broadcast(event: .attendedTransferStarted)
        }
    }

    public func callUpdated(_ call: VoIPLibCall, message: String) {
        pil.writeLog("On callUpdated")
        callKitUpdateCurrentCall(call)
    }

    public func callConnected(_ call: VoIPLibCall) {
        pil.writeLog("Call has connected")
        callKitUpdateCurrentCall(call)
        pil.events.broadcast(event: .callConnected)
        pil.app.requestCallUi()
    }

    public func callEnded(_ call: VoIPLibCall) {
        pil.writeLog("Received call ended event")
        
        if pil.calls.isInTranfer {
            pil.writeLog("Call ended in transfer")
            if pil.calls.active?.state == .connected {
                pil.events.broadcast(event: .attendedTransferEnded)
            } else {
                pil.events.broadcast(event: .attendedTransferAborted)
            }
        } else {
            pil.writeLog("We are not currently in transfer so we will end all calls")
            pil.iOSCallKit.endAllCalls()
            self.voipLibCall = nil
            
            pil.events.broadcast(event: .callEnded)
        }
        transferSession = nil
    }
    
    public func error(_ call: VoIPLibCall, message: String) {
        callEnded(call)
        pil.writeLog("ERROR: \(message)")
    }
    
    private func callKitUpdateCurrentCall(_ call: VoIPLibCall) {
        let update = CXCallUpdate()
        update.hasVideo = false
        update.localizedCallerName = call.remoteNumber
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = true
        update.supportsDTMF = true
        
        pil.iOSCallKit.updateCall(update: update)
    }
}
