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
    
    internal var voipLibCall: VoipLibCall? = nil
    internal var transferSession: AttendedTransferSession? = nil
    
    var mergeInitiated = false
    
    var isInCall: Bool {
        get {
            voipLibCall != nil
        }
    }
    
    init(pil: PIL) {
        self.pil = pil
    }
        
    public func incomingCallReceived(_ incomingCall: VoipLibCall) {
        if !isInCall {
            pil.writeLog("Setting up the incoming call")
            mergeInitiated = false
            self.voipLibCall = incomingCall
            pil.events.broadcast(event: .incomingCallReceived(state: pil.sessionState))
            callKitUpdateCurrentCall(incomingCall)
        } else {
            pil.writeLog("Detecting incoming call received while already in call so not doing anything")
        }
    }

    public func outgoingCallCreated(_ call: VoipLibCall) {
        pil.writeLog("On outgoingCallCreated")
        if !isInCall {
            pil.writeLog("Setting up the outgoing call")
            mergeInitiated = false
            self.voipLibCall = call
            pil.iOSCallKit.reportOutgoingCallConnecting()
            pil.events.broadcast(event: .outgoingCallStarted(state: pil.sessionState))
            pil.app.requestCallUi()
        } else {
            guard self.pil.calls.isInTranfer else {
                pil.writeLog("Detected outgoing call creation while already in call so not doing anything")
                return
            }
            pil.writeLog("Setting up the second outgoing call for transfer")
            pil.events.broadcast(event: .attendedTransferStarted(state: pil.sessionState))
        }
    }

    public func callUpdated(_ call: VoipLibCall, message: String) {
        pil.writeLog("On callUpdated")
        callKitUpdateCurrentCall(call)
    }

    public func callConnected(_ call: VoipLibCall) {
        pil.writeLog("Call has connected")
        callKitUpdateCurrentCall(call)
        
        if pil.calls.isInTranfer {
            pil.events.broadcast(event: .attendedTransferConnected(state: pil.sessionState))
        } else {
            pil.events.broadcast(event: .callConnected(state: pil.sessionState))
            pil.app.requestCallUi()
        }
    }

    public func callEnded(_ call: VoipLibCall) {
        pil.writeLog("Received call ended event")
        
        if pil.calls.isInTranfer {
            pil.writeLog("Call ended in transfer")
            if mergeInitiated {
                pil.events.broadcast(event: .attendedTransferEnded(state: pil.sessionState))
                mergeInitiated = false
            } else {
                pil.events.broadcast(event: .attendedTransferAborted(state: pil.sessionState))
            }
        } else {
            pil.writeLog("We are not currently in transfer so we will end all calls")
            pil.iOSCallKit.endAllCalls()
            pil.events.broadcast(event: .callEnded(state: pil.sessionState))
            self.voipLibCall = nil
            mergeInitiated = false
        }
        transferSession = nil
    }
    
    public func error(_ call: VoipLibCall, message: String) {
        callEnded(call)
        pil.writeLog("ERROR: \(message)")
    }
    
    private func callKitUpdateCurrentCall(_ call: VoipLibCall) {
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
