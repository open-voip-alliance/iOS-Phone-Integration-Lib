//
//  MiddlewareDelegate.swift
//  PIL
//
//  Created by Chris Kontos on 22/01/2021.
//

import Foundation

public protocol MiddlewareDelegate {

    func respond(payload: NSDictionary, available: Bool)
    
    func tokenReceived(token: String)
}
