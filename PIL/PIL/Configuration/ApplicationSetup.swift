//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation

public struct ApplicationSetup {
    var middleware: MiddlewareDelegate? = nil
    let userAgent: String = "iOS PIL"
    
    public init(middleware: MiddlewareDelegate?) {
        self.middleware = middleware
    }
}
