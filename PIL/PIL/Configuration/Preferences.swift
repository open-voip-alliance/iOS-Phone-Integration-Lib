//
//  Preferences.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public struct Preferences {
    public init(useApplicationRingtone: Bool = true, codecs: [Codec] = [Codec.OPUS]) {
        self.useApplicationRingtone = useApplicationRingtone
        self.codecs = codecs
    }
    
    public let useApplicationRingtone: Bool
    public let codecs: [Codec]
}
