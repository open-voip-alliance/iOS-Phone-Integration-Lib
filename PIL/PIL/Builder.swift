//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import Swinject

let di: Container = {
    register(Container())
}()

public class Builder {

    public var preferences: Preferences = Preferences()
    public var auth: Auth?
    var applicationSetup: ApplicationSetup?
    
    internal init() {
        
    }

    internal func start() -> PIL {
        return PIL(applicationSetup: applicationSetup!)
    }
}

public func startIOSPIL(applicationSetup: ApplicationSetup) -> PIL {
    let builder = Builder()
    builder.applicationSetup = applicationSetup
    return builder.start()
}
