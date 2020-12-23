//
//  Auth.swift
//  PIL
//
//  Created by Chris Kontos on 17/12/2020.
//

import Foundation

struct Auth: Decodable {
    let username: String
    let password: String
    let domain: String
    let port: Int
    let secure: Bool
    
    var isValid: Bool {
        get {
            !username.isEmpty && !password.isEmpty && !domain.isEmpty && port != 0
        }
    }
    
    init(username: String, password: String, domain: String, port: Int, secure:Bool) {
        self.username = username
        self.password = password
        self.domain = domain
        self.port = port
        self.secure = secure
    }
}
