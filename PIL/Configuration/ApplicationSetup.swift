//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation

public struct ApplicationSetup {
    public init(
        middleware: Middleware? = nil,
        requestCallUi: @escaping () -> Void,
        userAgent: String = "iOS PIL",
        logDelegate: LogDelegate? = nil
    ) {
        self.middleware = middleware
        self.userAgent = userAgent
        self.requestCallUi = requestCallUi
        self.logDelegate = logDelegate
    }
    
    public let middleware: Middleware?
    public let requestCallUi: () -> Void
    public let userAgent: String
    public let logDelegate: LogDelegate?
}
