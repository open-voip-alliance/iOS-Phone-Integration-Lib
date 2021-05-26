//
//  Container.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import Swinject
import iOSVoIPLib
import CallKit
import AVFoundation

var register: (Container) -> Container = {
    
    $0.register(PIL.self) { _ in
        PIL.shared!
    }.inObjectScope(.container)
        
    $0.register(CallActions.self) { c in
        CallActions(
            controller: CXCallController(),
            pil: c.resolve(PIL.self)!,
            voipLib: c.resolve(VoIPLib.self)!,
            callManager: c.resolve(CallManager.self)!
        )
    }.inObjectScope(.container)
    
    $0.register(EventsManager.self) { c in
        EventsManager(
            calls: c.resolve(Calls.self)!
        )
    }.inObjectScope(.container)
    
    $0.register(Calls.self) { c in
        Calls(callManager: c.resolve(CallManager.self)!, factory: c.resolve(PILCallFactory.self)!)
    }.inObjectScope(.container)
    
    $0.register(AudioManager.self) { c in AudioManager(
        pil: c.resolve(PIL.self)!,
        voipLib: c.resolve(VoIPLib.self)!,
        audioSession: AVAudioSession.sharedInstance(),
        dtmfPlayer: c.resolve(DtmfPlayer.self)!
    ) }.inObjectScope(.container)
    
    $0.register(DtmfPlayer.self) { c in DtmfPlayer(
        pil: c.resolve(PIL.self)!
    ) }.inObjectScope(.container)
    
    $0.register(Contacts.self) { _ in Contacts() }.inObjectScope(.container)
    
    $0.register(PILCallFactory.self) { c in
        PILCallFactory(contacts: c.resolve(Contacts.self)!)
    }.inObjectScope(.container)
    
    $0.register(VoIPLib.self) { _ in VoIPLib.shared }.inObjectScope(.container)
    
    $0.register(CallManager.self) { c in
        CallManager(pil: c.resolve(PIL.self)!)
    }.inObjectScope(.container)
    
    $0.register(IOS.self) { c in
        IOS(pil: c.resolve(PIL.self)!)
    }.inObjectScope(.container)
    
    $0.register(VoIPLibHelper.self) { c in
        VoIPLibHelper(
            voipLib: c.resolve(VoIPLib.self)!,
            pil: c.resolve(PIL.self)!,
            callManager: c.resolve(CallManager.self)!
        )
    }.inObjectScope(.container)
    
    $0.register(IOSCallKit.self) { c in
        IOSCallKit(
            pil: c.resolve(PIL.self)!,
            voipLib: c.resolve(VoIPLib.self)!,
            callManager: c.resolve(CallManager.self)!
        )
    }.inObjectScope(.container)
    
    return $0
}




