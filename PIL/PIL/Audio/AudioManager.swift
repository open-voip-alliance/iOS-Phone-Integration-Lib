//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib

public class AudioManager {
    
    private let phoneLib: PhoneLib
    
    init(phoneLib: PhoneLib) {
        self.phoneLib = phoneLib
    }
    
    public var isMicrophoneMuted: Bool {
        get {
            phoneLib.isMicrophoneMuted
        }
    }
}
