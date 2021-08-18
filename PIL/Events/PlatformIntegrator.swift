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
    
    init(pil:PIL) {
        self.pil = pil
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
        case .callEnded:
            pil.iOSCallKit.endAllCalls()
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
    
    func callKitUpdateCurrentCall() {
        guard let call = pil.calls.activeVoipLibCall else {return} 
        
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
