//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public class Calls {

    private let callManager: CallManager
    private let factory: PILCallFactory
    
    public var active: PILCall? {
        get {
            factory.make(libraryCall: findActiveCall())
        }
    }

    public var inactive: PILCall? {
        get {
            factory.make(libraryCall: findInactiveCall())
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
    
    private func findActiveCall() -> Call? {
        if let transferSession = callManager.transferSession {
            return transferSession.to
        }
        
        return callManager.call
    }

    private func findInactiveCall() -> Call? {
        if let transferSession = callManager.transferSession {
            return transferSession.from
        }
        
        return nil
    }
}
