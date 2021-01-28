//
//  Actions.swift
//  PIL
//
//  Created by Chris Kontos on 15/01/2021.
//

import Foundation
import CallKit

class Actions {
    
    func performCallAction(action: (_: UUID) -> CXCallAction) {
//        guard let uuid = sip.call?.uuid else {
//            print("Unable to perform action on call as there is no active call")
//            return
//        }

//        let controller = CXCallController()
//        let action = action(uuid)
//
//        controller.request(CXTransaction(action: action)) { error in
//            if error != nil {
//                print("Failed to perform \(action.description) \(String(describing: error?.localizedDescription))")
//                DispatchQueue.main.async {
//                 self.dismiss(animated: true)
//                }
//            } else {
//                debugPrint("Performed \(action.description))")
//            }
//        }
    }

    func performMuteToggle() {
//        performCallAction { uuid in
//            CXSetMutedCallAction(call: uuid, muted: !phone.isMicrophoneMuted)
//        }
    }
    
    func performSpeakerToggle() {
    //        _ = phone.setSpeaker(phone.isSpeakerOn ? false : true)
    }
    
//    func transferButtonPressed(_ sender: SipCallingButton) { //wip
//        guard let call = call, call.simpleState == .inProgress else { return }
//        if call.session.state != .paused {
//            performCallAction { uuid in
//                CXSetHeldCallAction(call: uuid, onHold: true)
//            }
//        }
//
//        DispatchQueue.main.async {
//            self.performSegue(segueIdentifier: .setupTransfer)
//        }
//    }
    
    func performHoldToggle() {
//        performCallAction { uuid in
//            CXSetHeldCallAction(call: uuid, onHold: !(call?.session.state == .paused))
//        }
    }
    
    func performHangup() {
        performCallAction { uuid in
            CXEndCallAction(call: uuid)
        }
    }
}
