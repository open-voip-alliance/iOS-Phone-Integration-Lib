//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation

struct PILCall {
    let remoteNumber: String
    let displayName: String
    let state: CallState
    let direction: CallDirection
    let duration: Int
    let isOnHold: Bool
    let uuid: String
    let mos: Float
    let contact: Bool
}
