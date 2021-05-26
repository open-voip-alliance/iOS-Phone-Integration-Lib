//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSVoIPLib

public class Calls {

    private let callManager: CallManager
    private let factory: PILCallFactory
    
    /// The currently active call that is setup to send/receive audio.
    public var active: Call? {
        get {
            factory.make(voipLibCall: findActiveCall())
        }
    }

    /// The background call. This will only exist when a transfer is happening.
    /// This will be the initial call while connecting to the new call.
    public var inactive: Call? {
        get {
            factory.make(voipLibCall: findInactiveCall())
        }
    }

    public var isInCall: Bool {
        get {
            callManager.voipLibCall != nil
        }
    }
    
    public var isInTranfer: Bool {
        get {
            callManager.transferSession != nil
        }
    }
    
    init(callManager: CallManager, factory: PILCallFactory) {
        self.callManager = callManager
        self.factory = factory
    }
    
    private func findActiveCall() -> VoipLibCall? {
        if let transferSession = callManager.transferSession {
            return transferSession.to
        }
        
        return callManager.voipLibCall
    }

    private func findInactiveCall() -> VoipLibCall? {
        if let transferSession = callManager.transferSession {
            return transferSession.from
        }
        
        return nil
    }
}
