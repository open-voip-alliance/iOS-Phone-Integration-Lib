//
//  EventsManager.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public class EventsManager {
    
    private let callFactory: PILCallFactory
    private let callManager: CallManager
    private var listeners = [ObjectIdentifier : EventListener]()
    
    init(callManager: CallManager, callFactory: PILCallFactory) {
        self.callFactory = callFactory
        self.callManager = callManager
    }
    
    public func listen(delegate: PILEventDelegate) {
        let id = ObjectIdentifier(delegate)
        listeners[id] = EventListener(listener: delegate)
    }
    
    public func stopListening(delegate: PILEventDelegate) {
        let id = ObjectIdentifier(delegate)
        listeners.removeValue(forKey: id)
    }
    
    internal func broadcast(event: Event, call: Call? = nil) {
        for (id, listener) in listeners {
            guard let delegate = listener.listener else {
                listeners.removeValue(forKey: id)
                continue
            }
            
            if let call = call {
                delegate.onEvent(event: event, call: self.callFactory.make(libraryCall: call))
            } else {
                if (callManager.isInCall) {
                    delegate.onEvent(event: event, call: self.callFactory.make(libraryCall: callManager.call))
                } else {
                    delegate.onEvent(event: event, call: nil)
                }
            }
        }
    }

    struct EventListener {
        weak var listener: PILEventDelegate?
    }
}
