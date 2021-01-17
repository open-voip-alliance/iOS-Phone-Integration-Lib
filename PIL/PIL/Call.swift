//
//  Call.swift
//  PIL
//
//  Created by Chris Kontos on 22/12/2020.
//

import Foundation
import PhoneLib

public class Call {

    let session: Session
    let direction: Direction
    let uuid: UUID

    var isIncoming: Bool {
        get {
            self.direction == Direction.inbound
        }
    }

    var simpleState: SimpleState {
        get {
            switch session.state {
            case .idle:
                return SimpleState.initializing
            case .incomingReceived, .outgoingDidInitialize, .outgoingProgress, .outgoingRinging:
                return SimpleState.ringing
            case .connected, .streamsRunning, .outgoingEarlyMedia, .earlyUpdatedByRemote, .earlyUpdating,
                 .incomingEarlyMedia, .paused, .pausing, .resuming, .referred, .pausedByRemote, .updatedByRemote,
                 .updating:
                return SimpleState.inProgress
            case .ended, .released, .error:
                return SimpleState.finished
            }
        }
    }

    var duration: Int {
        get { session.durationInSec ?? 0 }
    }

    var state: SessionState {
        get { session.state }
    }

    var remoteNumber: String {
        get { session.remoteNumber }
    }

    var displayName: String? {
        get { session.displayName }
    }

    init(session: Session, direction: Direction) {
        self.direction = direction
        self.uuid = UUID.init()
        self.session = session
    }

    init(session: Session, direction: Direction, uuid: UUID) {
        self.direction = direction
        self.uuid = uuid
        self.session = session
    }
}
