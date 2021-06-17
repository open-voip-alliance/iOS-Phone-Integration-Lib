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
    
    /// Inspect the contents of the push notification to determine whether this notification should be processed
    /// as a call notification.
    ///
    /// - Returns: If TRUE is returned, processing of the push message will continue as if it is a call. If FALSE is
    ///     returned, nothing further will be done with this notification. This will be ignored if the [PKPushType] is
    ///     .voip as it is required that this be handled as a call.
    func inspect(payload: PKPushPayload, type: PKPushType) -> Bool
}

public struct IncomingPayloadCallDetail {
    public let phoneNumber: String
    public let callerId: String
    
    public init(phoneNumber: String, callerId: String) {
        self.phoneNumber = phoneNumber
        self.callerId = callerId
    }
}
