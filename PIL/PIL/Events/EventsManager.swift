//
//  EventsManager.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public class EventsManager {
    
    private let calls: Calls
    private var listeners = [ObjectIdentifier : EventListener]()
    
    init(calls: Calls) {
        self.calls = calls
    }
    
    public func listen(delegate: PILEventDelegate) {
        let id = ObjectIdentifier(delegate)
        listeners[id] = EventListener(listener: delegate)
    }
    
    public func stopListening(delegate: PILEventDelegate) {
        let id = ObjectIdentifier(delegate)
        listeners.removeValue(forKey: id)
    }
    
    internal func broadcast(event: Event) {
        for (id, listener) in listeners {
            guard let delegate = listener.listener else {
                listeners.removeValue(forKey: id)
                continue
            }
            
            if (calls.isInCall) {
                delegate.onEvent(event: event, call: calls.active)
            } else {
                delegate.onEvent(event: event, call: nil)
            }
        }
    }

    struct EventListener {
        weak var listener: PILEventDelegate?
    }
}
