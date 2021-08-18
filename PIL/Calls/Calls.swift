//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSVoIPLib

public class Calls {

    // MARK: Properties
    private let callList: CallList
    private let factory: PILCallFactory
    private let MAX_CALLS = 2
    
    var transferSession: AttendedTransferSession? = nil
    
    var isInCall: Bool {
        get {
            !callList.callArray.isEmpty
        }
    }
    
    var activeVoipLibCall: VoipLibCall? {
        get {
            callList.callArray.last
        }
    }

    
    var inactiveVoipLibCall: VoipLibCall? {
        get {
            isInTransfer ? callList.callArray.first : nil
        }
    }
    
    /// The currently active call that is setup to send/receive audio.
    public var activeCall: Call? {
        get {
            factory.make(voipLibCall: activeVoipLibCall)
        }
    }
    
    /// The background call. This will only exist when a transfer is happening.
    /// This will be the initial call while connecting to the new call.
    public var inactiveCall: Call? {
        get {
            factory.make(voipLibCall: inactiveVoipLibCall)
        }
    }
    
    public var isInTransfer: Bool {
        get {
            callList.callArray.count >= 2
        }
    }
    
    // MARK: Initialization
    init(factory: PILCallFactory) {
        self.factory = factory
        self.callList = CallList(maxCalls: MAX_CALLS)
    }
    
    public func add(voipLibCall: VoipLibCall) {
        callList.add(call: voipLibCall)
    }
    
    public func remove(voipLibCall: VoipLibCall) {
        callList.remove(call: voipLibCall)
    }
}
