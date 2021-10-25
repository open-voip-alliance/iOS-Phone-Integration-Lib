//
//  Preferences.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSVoIPLib

public struct Preferences: Equatable {
    public let useApplicationRingtone: Bool
    public let codecs: [Codec]

    public init(useApplicationRingtone: Bool = true, codecs: [Codec] = [Codec.OPUS]) {
        self.useApplicationRingtone = useApplicationRingtone
        self.codecs = codecs
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.useApplicationRingtone == rhs.useApplicationRingtone && lhs.codecs.elementsEqual(rhs.codecs)
    }
}
