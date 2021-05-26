//
//  Event.swift
//  PIL
//
//  Created by Jeremy Norman on 05/03/2021.
//

import Foundation

public enum Event {
    case outgoingCallStarted
    case incomingCallReceived
    case callEnded
    case callConnected
    case callDurationUpdated
    
    case outgoingCallSetupFailed
    case incomingCallSetupFailed
    
    case attendedTransferStarted
    case attendedTransferAborted
    case attendedTransferEnded
}
