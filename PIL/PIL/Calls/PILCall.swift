//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public struct PILCall {
    let remoteNumber: String
    let displayName: String
    let state: CallState
    let direction: CallDirection
    let duration: Int
    public let isOnHold: Bool
    let uuid: UUID
    let mos: Float
//TODO:    let contact: Contact?
    let isIncoming: Bool
    let session: Session
    public let sessionState: SessionState
    
    
    init(phoneNumber: String, displayName: String, state: CallState, direction: CallDirection, duration: Int, isOnHold: Bool, uuid: UUID, mos: Float, isIncoming: Bool, session: Session, sessionState: SessionState) {
        self.remoteNumber = phoneNumber
        self.displayName = displayName
        self.state = state
        self.direction = direction
        self.duration = duration
        self.isOnHold = isOnHold
        self.uuid = uuid
        self.mos = mos
//TODO:        self.contact = contact
        self.isIncoming = isIncoming
        self.session = session
        self.sessionState = sessionState
    }
}
