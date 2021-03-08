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
    case callUpdated
    case callConnected
    
    case outgoingCallSetupFailed
    case incomingCallSetupFailed
}
