//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public class PILCallFactory {
    
    public func make(phoneLibCall:Call) -> PILCall {
        let remoteNumber = phoneLibCall.remoteNumber
        let displayName = phoneLibCall.displayName ?? ""
        let callState = convertCallState(phoneLibCallState: phoneLibCall.state)
        let direction: CallDirection = phoneLibCall.direction == .inbound ? .inbound : .outbound
        let duration = phoneLibCall.durationInSec ?? 0
        let isOnHold = (phoneLibCall.state == .pausedByRemote || phoneLibCall.state == .paused)
        let uuid = phoneLibCall.callId
        let mos = phoneLibCall.getAverageRating()
        //TODO: contact =
        let isIncoming = phoneLibCall.isIncoming
        let phoneLibCallState = phoneLibCall.state
    
        let call = PILCall(remoteNumber: remoteNumber, displayName: displayName, state: callState, direction: direction, duration: duration, isOnHold: isOnHold, uuid: uuid, mos: mos, isIncoming: isIncoming, phoneLibCall: phoneLibCall, phoneLibCallState: phoneLibCallState)
        return call
        
        //wip check if UUID and Direction have correct values / get rid of isIncoming since we have direction now
    }
    
    private func convertCallState(phoneLibCallState: PhoneLibCallState) -> CallState {
        switch phoneLibCallState {
        case .idle:
            return .initializing
        case .incomingReceived, .outgoingDidInitialize, .outgoingProgress, .outgoingRinging:
            return .ringing
        case .connected, .streamsRunning, .outgoingEarlyMedia, .earlyUpdatedByRemote, .earlyUpdating, .incomingEarlyMedia, .pausing, .resuming, .referred, .updatedByRemote, .updating:
            return .connected
        case .paused:
            return .heldByLocal
        case .pausedByRemote:
            return .heldByRemote
        case .error:
            return .error
        case .ended, .released:
            return .ended
        }
    }
}
