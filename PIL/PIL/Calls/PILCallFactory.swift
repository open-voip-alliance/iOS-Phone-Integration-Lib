//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public class PILCallFactory {
    
    public func make(session:Session) -> PILCall {
        let remoteNumber = session.remoteNumber
        let displayName = session.displayName ?? ""
        let state = convertCallState(state: session.state)
        let direction: CallDirection = session.direction == .inbound ? .inbound : .outbound
        let duration = session.durationInSec ?? 0
        let isOnHold = (session.state == .pausedByRemote || session.state == .paused)
        let uuid = session.sessionId
        let mos = session.getAverageRating()
        let isIncoming = session.isIncoming
        let session = session
        let sessionState = session.state
        //TODO: contact =
        
        let call = PILCall(remoteNumber: remoteNumber, displayName: displayName, state: state, direction: direction, duration: duration, isOnHold: isOnHold, uuid: uuid, mos: mos, isIncoming: isIncoming, session: session, sessionState: sessionState)
        return call
        
        //wip check if UUID AND Direction have correct values
    }
    
    private func convertCallState(state: SessionState) -> CallState {
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
