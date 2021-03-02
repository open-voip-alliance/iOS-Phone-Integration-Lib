//
//  Container.swift
//  PIL
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import Swinject

var register: (Container) -> Container = {
    
    $0.register(CallActions.self, factory: { _ in CallActions() })
    $0.register(EventsManager.self, factory: { _ in EventsManager() })
    $0.register(Calls.self, factory: { _ in Calls() })
    $0.register(AudioManager.self, factory: { _ in AudioManager() })
    $0.register(PILCallFactory.self, factory: { _ in PILCallFactory() })
    
    return $0
}




