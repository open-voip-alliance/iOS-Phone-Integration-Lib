//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSVoIPLib

public typealias VoipLibCallState = iOSVoIPLib.CallState

public struct Call {
    public let remoteNumber: String
    public let displayName: String
    public let state: CallState
    public let direction: CallDirection
    public let duration: Int
    public let isOnHold: Bool
    public let uuid: UUID
    public let mos: Float
    public let contact: Contact?
    
    public var remotePartyHeading: String {
        get {
            if let contact = contact {
                return contact.name
            }
            
            if !displayName.isEmpty {
                return displayName
            }
            
            return remoteNumber
        }
    }
    
    public var remotePartySubheading: String {
        get {
            if contact != nil || !displayName.isEmpty {
                return remoteNumber
            }
            
            return ""
        }
    }
    
    public var prettyDuration: String {
        let formatter = DateComponentsFormatter()
        if duration < 3600 {
            formatter.allowedUnits = [.minute, .second]
        } else{
            formatter.allowedUnits = [.hour, .minute, .second]
        }
        
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: TimeInterval(duration)) ?? ""
    }
}
