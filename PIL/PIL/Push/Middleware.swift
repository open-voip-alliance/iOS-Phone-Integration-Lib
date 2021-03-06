//
//  MiddlewareDelegate.swift
//  PIL
//
//  Created by Chris Kontos on 22/01/2021.
//

import Foundation
import PushKit

public protocol Middleware {

    func respond(payload: PKPushPayload, available: Bool)
    
    func tokenReceived(token: String)
    
    func extractCallDetail(from payload: PKPushPayload) -> IncomingPayloadCallDetail
}

public struct IncomingPayloadCallDetail {
    public init(phoneNumber: String, callerId: String) {
        self.phoneNumber = phoneNumber
        self.callerId = callerId
    }
    
    public let phoneNumber: String
    public let callerId: String
}
