//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public typealias PhoneLibCall = iOSPhoneLib.Call

public class PILCallFactory {
    
    private let contacts: Contacts
    
    init(contacts: Contacts) {
        self.contacts = contacts
    }
    
    public func make(libraryCall: PhoneLibCall?) -> PILCall? {
        guard let libraryCall = libraryCall else {
            return nil
        }
            
        return PILCall(
            remoteNumber: libraryCall.remoteNumber,
            displayName: libraryCall.displayName ?? "",
            state: convertCallState(state: libraryCall.state),
            direction: libraryCall.direction == .inbound ? .inbound : .outbound,
            duration: libraryCall.durationInSec ?? 0,
            isOnHold: (libraryCall.state == .pausedByRemote || libraryCall.state == .paused),
            uuid: UUID.init(),
            mos: libraryCall.quality.average,
            contact: contacts.find(number: libraryCall.remoteNumber)
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
