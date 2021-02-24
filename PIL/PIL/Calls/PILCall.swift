//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import PhoneLib

public struct PILCall {
    let direction: CallDirection
    let uuid: UUID
    let session: Session

    public var state: CallState {
        get {
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
    
    var isIncoming: Bool {
        get {
            self.direction == CallDirection.inbound
        }
    }
    
    public var isOnHold: Bool {
        get {
            self.state == .heldByRemote || self.state == .heldByLocal
        }
    }

    var duration: Int {
        get { session.durationInSec ?? 0 }
    }

    public var sessionState: SessionState {
        get { session.state }
    }

    var remoteNumber: String {
        get { session.remoteNumber }
    }

    var displayName: String? {
        get { session.displayName }
    }
    
    var mos: Float {
        get {session.getAverageRating()}
    }
    
    var contanct: Bool? {
        //TODO: Implement contact check
        get {false}
    }

    init(session: Session, direction: CallDirection) {
        self.direction = direction
        self.uuid = UUID.init()
        self.session = session
    }

    init(session: Session, direction: CallDirection, uuid: UUID) {
        self.direction = direction
        self.uuid = uuid
        self.session = session
    }
}


