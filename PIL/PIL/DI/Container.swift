//
//  Container.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import Swinject
import iOSPhoneLib
import CallKit

var register: (Container) -> Container = {
    
    $0.register(PIL.self) { _ in
        PIL.shared!
    }.inObjectScope(.container)
        
    $0.register(CallActions.self) { c in
        CallActions(
            controller: CXCallController(),
            pil: c.resolve(PIL.self)!,
            phoneLib: c.resolve(PhoneLib.self)!,
            callManager: c.resolve(CallManager.self)!
        )
    }.inObjectScope(.container)
    
    $0.register(EventsManager.self) { c in
        EventsManager(callFactory: c.resolve(PILCallFactory.self)!)
    }.inObjectScope(.container)
    
    $0.register(Calls.self) { c in
        Calls(callManager: c.resolve(CallManager.self)!, factory: c.resolve(PILCallFactory.self)!)
        
    }.inObjectScope(.container)
    
    $0.register(AudioManager.self) { c in AudioManager(phoneLib: c.resolve(PhoneLib.self)!) }.inObjectScope(.container)
    
    $0.register(PILCallFactory.self) { _ in PILCallFactory() }.inObjectScope(.container)
    
    $0.register(PhoneLib.self) { _ in PhoneLib.shared }.inObjectScope(.container)
    
    $0.register(CallManager.self) { c in
        CallManager(pil: c.resolve(PIL.self)!)
    }.inObjectScope(.container)
    
    $0.register(PhoneLibHelper.self) { c in
        PhoneLibHelper(
            phoneLib: c.resolve(PhoneLib.self)!,
            pil: c.resolve(PIL.self)!,
            callManager: c.resolve(CallManager.self)!
        )
    }.inObjectScope(.container)
    
    $0.register(IOSCallKit.self) { c in
        IOSCallKit(
            pil: c.resolve(PIL.self)!,
            phoneLib: c.resolve(PhoneLib.self)!,
            callManager: c.resolve(CallManager.self)!
        )
    }.inObjectScope(.container)
    
    return $0
}




