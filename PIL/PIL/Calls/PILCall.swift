//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import PhoneLib

public struct PILCall {
    let direction: CallDirection
    let uuid: UUID
    let session: Session
    var state: CallState!
    let isIncoming: Bool
    public let isOnHold: Bool
    let duration: Int
    public let sessionState: SessionState
    let remoteNumber: String
    let displayName: String
    let mos: Float
    //TODO: let contact: Bool?
    
    init(session: Session, direction: CallDirection, uuid:UUID = UUID.init()) {
        self.direction = direction
        self.session = session
        self.uuid = uuid
        
        state = PILCall.convertCallState(session: session)
        isIncoming = direction == CallDirection.inbound
        isOnHold = (session.state == .pausedByRemote || session.state == .paused)
        duration = session.durationInSec ?? 0
        sessionState = session.state
        remoteNumber = session.remoteNumber
        displayName = session.displayName ?? ""
        mos = session.getAverageRating()
        //TODO: contact =
    }

    private static func convertCallState(session: Session) -> CallState {
        switch session.state {
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
