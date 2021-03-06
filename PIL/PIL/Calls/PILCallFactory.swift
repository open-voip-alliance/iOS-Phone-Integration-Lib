//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public typealias PhoneLibCall = iOSPhoneLib.Call

public class PILCallFactory {
    
    public func make(libraryCall: PhoneLibCall?) -> PILCall? {
        guard let libraryCall = libraryCall else {
            return nil
        }
        
        let remoteNumber = libraryCall.remoteNumber
        let displayName = libraryCall.displayName ?? ""
        let state = convertCallState(state: libraryCall.state)
        let direction: CallDirection = libraryCall.direction == .inbound ? .inbound : .outbound
        let duration = libraryCall.durationInSec ?? 0
        let isOnHold = (libraryCall.state == .pausedByRemote || libraryCall.state == .paused)
        let uuid = UUID.init()
        let mos = libraryCall.quality.average
        
        return PILCall(
            remoteNumber: remoteNumber,
            displayName: displayName,
            state: state, direction: direction,
            duration: duration,
            isOnHold: isOnHold,
            uuid: uuid,
            mos: mos
        )
    }
    
    private func convertCallState(state: iOSPhoneLib.CallState) -> CallState {
        switch state {
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
