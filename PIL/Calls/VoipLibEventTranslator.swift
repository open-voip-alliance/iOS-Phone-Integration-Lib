//
//  VoipLibEventTranslator.swift
//  PIL
//
//  Created by Jeremy Norman on 04/03/2021.
//

import Foundation
import iOSVoIPLib
import CallKit

class VoipLibEventTranslator: CallDelegate {

    private let pil: PIL
    
    init(pil: PIL) {
        self.pil = pil
    }
    
    // MARK: CallDelegate methods
    public func incomingCallReceived(_ incomingCall: VoipLibCall) {
        pil.writeLog("VoipLib event incomingCallReceived: \(incomingCall.callId)")
        
        if (pil.calls.isInCall) {
            pil.writeLog("Ignoring incoming call: \(incomingCall.callId) as we are in a call already")
            return
        }
        
        pil.writeLog("Setting up the incoming call")
        
        pil.calls.add(voipLibCall: incomingCall)
        
        pil.events.broadcast(event: .incomingCallReceived(state: pil.sessionState))
    }

    public func outgoingCallCreated(_ call: VoipLibCall) {
        pil.writeLog("VoipLib event outgoingCallCreated: \(call.callId)")
        
        pil.calls.add(voipLibCall: call)
        
        if (pil.calls.isInTransfer) {
            pil.events.broadcast(event: .attendedTransferStarted(state: pil.sessionState))
        } else {
            pil.writeLog("Setting up the outgoing call")
            pil.events.broadcast(event: .outgoingCallStarted(state: pil.sessionState))
        }
    }

    public func callUpdated(_ call: VoipLibCall, message: String) {
        pil.writeLog("VoipLib event callUpdated")
        pil.events.broadcast(event: .callStateUpdated(state: pil.sessionState))
    }

    public func callConnected(_ call: VoipLibCall) {
        pil.writeLog("VoipLib event callConnected")
        
        if pil.calls.isInTransfer {
            pil.events.broadcast(event: .attendedTransferConnected(state: pil.sessionState))
        } else {
            pil.events.broadcast(event: .callConnected(state: pil.sessionState))
        }
    }

    public func callEnded(_ call: VoipLibCall) {
        pil.writeLog("VoipLib event callEnded")
        
        let currentSessionState = pil.sessionState
        let isInTransfer = pil.calls.isInTransfer
        
        pil.calls.remove(voipLibCall: call)
        
        if isInTransfer {
            pil.writeLog("Call ended in transfer")
            pil.events.broadcast(event: .attendedTransferAborted(state: currentSessionState))
        } else {
            pil.events.broadcast(event: .callEnded(state: currentSessionState))
        }
    }
    
    func attendedTransferMerged(_ call: VoipLibCall) {
        pil.writeLog("VoipLib event attendedTransferMerged")
        
        pil.calls.remove(voipLibCall: call)
        
        pil.events.broadcast(event: .attendedTransferEnded(state: pil.sessionState))
    }
    
    public func error(_ call: VoipLibCall, message: String) {
        pil.writeLog("VoipLib event error: \(message)")
        callEnded(call)
    }
}
