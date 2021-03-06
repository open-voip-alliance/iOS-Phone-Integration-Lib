//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public struct PILCall {
    public let remoteNumber: String
    public let displayName: String
    public let state: CallState
    public let direction: CallDirection
    public let duration: Int
    public let isOnHold: Bool
    public let uuid: UUID
    public let mos: Float
}
