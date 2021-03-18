//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import Swinject

let di: Container = {
    register(Container())
}()

public class Builder {

    public var preferences: Preferences?
    public var auth: Auth?
    var applicationSetup: ApplicationSetup?
    
    internal init() {}

    internal func start() -> PIL {
        let pil = PIL(applicationSetup: applicationSetup!)
        
        if let auth = self.auth {
            pil.auth = auth
        }
        
        if let preferences = self.preferences {
            pil.preferences = preferences
        } else {
            pil.preferences = Preferences()
        }
        
        return pil
    }
}

/// Initialise the iOS PIL, this should be called in your AppDelegate's didFinishLaunchingWithOptions method.
public func startIOSPIL(applicationSetup: ApplicationSetup, auth: Auth? = nil, preferences: Preferences? = nil, autoStart: Bool = true) -> PIL {
    let builder = Builder()
    builder.applicationSetup = applicationSetup
    builder.auth = auth
    builder.preferences = preferences
    let pil = builder.start()
    
    if autoStart {
        pil.start()
    }
    
    return pil
}
