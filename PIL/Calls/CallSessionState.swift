//
//  CallSessionState.swift
//  PIL
//
//  Created by Chris Kontos on 03/05/2021.
//

import Foundation

public class CallSessionState {
    
    public var activeCall: PILCall?
    public var inactiveCall: PILCall? //wip optionals?
    public var audioState: AudioState
    
    init(activeCall: PILCall?, inactiveCall: PILCall?, audioState: AudioState){
        self.activeCall = activeCall
        self.inactiveCall = inactiveCall
        self.audioState = audioState
    }
}
