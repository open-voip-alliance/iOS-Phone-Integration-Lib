//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import CallKit
import iOSPhoneLib

public class CallActions {
    
    lazy var phoneLib: PhoneLib = PhoneLib.shared
     
    // MARK: Callkit actions
    public func performHold() {
        performCallAction { uuid in
            CXSetHeldCallAction(call: uuid, onHold: true)
        }
    }
    
    public func performUnhold() {
        performCallAction { uuid in
            CXSetHeldCallAction(call: uuid, onHold: false)
        }
    }
    
    public func performToggleHold() {
        let pil = PIL.shared
        performCallAction { uuid in
            CXSetHeldCallAction(call: uuid, onHold: !(pil?.call?.sessionState == .paused))
        }
    }
    
    public func performMute() {
        guard let pil = PIL.shared else {return}
        performCallAction { uuid in
            CXSetMutedCallAction(call: uuid, muted: !pil.isMicrophoneMuted)
        }
    }
    
    public func beginAttendedTransfer(number: String) {
        //TODO:
    }
    
    public func completeAttendedTransfer() {
        //TODO:
    }
    
    public func answer() {
        //TODO:
    }
    
    public func decline() {
        //TODO:
    }
    
    public func end() {
        let pil = PIL.shared
        guard let call = pil?.call, call.state != .ended else { return }

        performCallAction { uuid in
            CXEndCallAction(call: uuid)
        }
    }
    
    func performCallAction(action: (_: UUID) -> CXCallAction) {
        let pil = PIL.shared
        guard let uuid = pil?.call?.uuid else {
            print("Unable to perform action on call as there is no active call")
            return
        }

        let controller = CXCallController()
        let action = action(uuid)

        controller.request(CXTransaction(action: action)) { error in
            if error != nil {
                print("Failed to perform \(action.description) \(String(describing: error?.localizedDescription))")
            } else {
                debugPrint("Performed \(action.description))")
            }
        }
    }
    
    // MARK: PhoneLib actions
    public func call(number: String) -> PILCall? {
        var outgoingCall: PILCall? = nil
        print("Attempting to call.")
        if let session = phoneLib.call(to: number) {
//wip outgoingCall = PILCall(session: session, direction: CallDirection.outbound, uuid:session.sessionId) 
            outgoingCall = PILCallFactory.make(session:session)
        }
        return outgoingCall
    }
    
    public func setMicrophone(muted: Bool) {
        phoneLib.setMicrophone(muted: muted)
    }
    
    public func setHold(call: PILCall, onHold: Bool) -> Bool {
        return phoneLib.setHold(session: call.session, onHold: onHold)
    }
    
    public func sendDtmf(dtmf: String) {
        guard let pil = PIL.shared,
              let session = pil.call?.session else {return}
        phoneLib.sendDtmf(session: session, dtmf: dtmf)
    }
    
    public func toggleSpeaker() {
        _ = phoneLib.setSpeaker(phoneLib.isSpeakerOn ? false : true)
    }
    
    public func end(call: PILCall) -> Bool {
        return phoneLib.endCall(for: call.session)
    }
}
