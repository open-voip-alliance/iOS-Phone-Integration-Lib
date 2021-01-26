//
//  MiddlewareDelegate.swift
//  PIL
//
//  Created by Chris Kontos on 22/01/2021.
//

import Foundation

public protocol MiddlewareDelegate: class {

    /**
     *  Tells the middleware that the user is able to receive the call.
     *
     *  @param payload that is first received from the middleware.
     *  @param available if the user is avaiable to receive the call.
     *  @param completion optional block giving access to an error object when one occurs.
     */
    func respond(payload:NSDictionary, available:Bool, completion:((Error?) -> ())?)
    
    func tokenReceived(token: String)
}
