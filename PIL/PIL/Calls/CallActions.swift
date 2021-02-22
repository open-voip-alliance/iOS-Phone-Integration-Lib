//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import CallKit

public class CallActions {
        
    public func hold() {
        performCallAction { uuid in
            CXSetHeldCallAction(call: uuid, onHold: true)
        }
    }
    
    public func unhold() {
        performCallAction { uuid in
            CXSetHeldCallAction(call: uuid, onHold: false)
        }
    }
    
    public func toggleHold() {
        let pil = PIL.shared
        performCallAction { uuid in
            CXSetHeldCallAction(call: uuid, onHold: !(pil?.call?.session.state == .paused))
        }
    }
    
    public func mute() {
        guard let pil = PIL.shared else {return}
        performCallAction { uuid in
            CXSetMutedCallAction(call: uuid, muted: !pil.isMicrophoneMuted)
        }
    }
    
    public func toggleSpeaker() {
        guard let pil = PIL.shared else {return}
        pil.toggleSpeaker()
    }
    
    public func sendDtmf(dtmf: String) {
        // TODO
    }
    
    public func beginAttendedTransfer(number: String) {
        // TODO
    }
    
    public func completeAttendedTransfer() {
        // TODO
    }
    
    public func answer() {
        // TODO
    }
    
    public func decline() {
        // TODO
    }
    
    public func end() {
        let pil = PIL.shared
        guard let call = pil?.call, call.simpleState != .finished else { return }

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
}
