//
//  VoIPPushPayload.swift
//  PIL
//
//  Created by Chris Kontos on 23/12/2020.
//

import Foundation
import PushKit

struct VoIPPushPayload {
    let phoneNumber: String
    let uuid: UUID
    let responseUrl: String
    let callerId: String?
    var callerName: String {
        get {
            callerId ?? phoneNumber
        }
    }
    let payload: PKPushPayload
}
