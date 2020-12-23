//
//  SipSDKDelegate.swift
//  PhoneLib
//
//  Created by Fabian Giger on 02/07/2020.
//

import Foundation

protocol SipSDKDelegate: SessionDelegate {
    func getActiveSessions() -> [Session]
}
