//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import CallKit
import iOSVoIPLib

public class CallActions {
    
    private let controller: CXCallController
    private let pil: PIL
    private let phoneLib: PhoneLib
    private let callManager: CallManager
    
    init(controller: CXCallController, pil: PIL, phoneLib: PhoneLib, callManager: CallManager) {
        self.controller = controller
        self.pil = pil
        self.phoneLib = phoneLib
        self.callManager = callManager
    }

    public func hold() {
        performCallAction { uuid -> CXCallAction in
            CXSetHeldCallAction(call: uuid, onHold: true)
        }
    }
    
    public func unhold() {
        performCallAction { uuid -> CXCallAction in
            CXSetHeldCallAction(call: uuid, onHold: false)
        }
    }
    
    public func toggleHold() {
        let isOnHold: Bool = pil.calls.active!.isOnHold
        
        if isOnHold {
            unhold()
        } else {
            hold()
        }
    }
    
    public func answer() {
        performCallAction { uuid -> CXCallAction in
            CXAnswerCallAction(call: uuid)
        }
    }
    
    public func decline() {
        performCallAction { uuid -> CXCallAction in
            CXEndCallAction(call: uuid)
        }
    }
    
    public func end() {
        performCallAction { uuid -> CXCallAction in
            CXEndCallAction(call: uuid)
        }
    }
    
    public func mute() {
        performCallAction { uuid -> CXCallAction in
            CXSetMutedCallAction(call: uuid, muted: true)
        }
    }
    
    public func unmute() {
        performCallAction { uuid -> CXCallAction in
            CXSetMutedCallAction(call: uuid, muted: false)
        }
    }
    
    public func toggleMute() {
        let isOnMute: Bool = pil.audio.isMicrophoneMuted
        
        if isOnMute {
            unmute()
        } else {
            mute()
        }
    }
    
    public func sendDtmf(dtmf: String) {
        performCallAction { uuid -> CXCallAction in
            CXPlayDTMFCallAction(call: uuid, digits: dtmf, type: .singleTone)
        }
    }
    
    public func beginAttendedTransfer(number: String) {
        callExists { call in
            self.callManager.transferSession = phoneLib.actions(call: call).beginAttendedTransfer(to: number)
        }
    }
    
    public func completeAttendedTransfer() {
        if let transferSession = callManager.transferSession {
            phoneLib.actions(call: transferSession.from).finishAttendedTransfer(attendedTransferSession: transferSession)
        }
    }
    
    func performCallAction(_ callback: (UUID) -> CXCallAction) {
        guard let uuid = pil.iOSCallKit.uuid else { return }
        let action = callback(uuid)
        
        controller.request(CXTransaction(action: action)) { error in
            if error != nil {
                print("Failed to perform \(action.description) \(String(describing: error?.localizedDescription))")
            } else {
                debugPrint("Performed \(action.description))")
            }
        }
    }
   
    private func callExists(callback: (Call) -> Void) {
        if let transferSession = callManager.transferSession {
            callback(transferSession.to)
            return
        }
        
        if let call = callManager.call {
            callback(call)
            pil.events.broadcast(event: .callUpdated)
            return
        }
    }
}
