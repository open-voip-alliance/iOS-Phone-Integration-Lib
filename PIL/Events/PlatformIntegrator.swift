//
//  PlatformIntegrator.swift
//  PIL
//
//  Created by Chris Kontos on 03/08/2021.
//

import Foundation
import iOSVoIPLib
import CallKit	

// Listens to PIL events and performs the necessary actions in the Callkit.
class PlatformIntegrator: PILEventDelegate {
    
    private let pil: PIL
    private let missedCallNotification: MissedCallNotification
    
    init(pil: PIL, missedCallNotification: MissedCallNotification) {
        self.pil = pil
        self.missedCallNotification = missedCallNotification
    }
    
    func onEvent(event: Event) {
        pil.writeLog("PlatformIntegrator received \(event) event")
        
        handle(event: event)
    }
    
    private func handle(event: Event) {
        
        switch event {
            case .outgoingCallStarted:
                pil.iOSCallKit.reportOutgoingCallConnecting()
                pil.app.requestCallUi()
            case .callEnded(let state):
                pil.iOSCallKit.endAllCalls()
                if let call = state.activeCall {
                    notifyIfMissedCall(call: call)
                }
                fallthrough
            case .attendedTransferAborted,
                 .attendedTransferEnded:
                pil.calls.transferSession = nil
            case .callConnected:
                callKitUpdateCurrentCall()
                pil.app.requestCallUi()
            case.attendedTransferConnected,
                .incomingCallReceived,
                .callStateUpdated:
                callKitUpdateCurrentCall()
            default:
                return
        }
    }
    
    func notifyIfMissedCall(call: Call) {
        let center = UNUserNotificationCenter.current()
        
        if call.duration > 0 { return }
        
        if call.direction != .inbound { return }
        
        if !pil.app.notifyOnMissedCall { return }
        
        if #available(iOS 12.0, *) {
            missedCallNotification.notify(call: call)
        }
    }
    
    func callKitUpdateCurrentCall() {
        if let call = pil.calls.activeCall {
            pil.iOSCallKit.updateCall(call: call)
        }
    }
}
