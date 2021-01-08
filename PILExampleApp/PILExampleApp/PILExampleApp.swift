//
//  PILExampleApp.swift
//  PILExampleApp
//
//  Created by Chris Kontos on 28/12/2020.
//

import SwiftUI
import PIL

let pil = PIL.shared

var username = "497920083"
var password = "pxNnxaxb56AK8hr"
var secure = true
var domain = "sip.encryptedsip.com"
var port = 5060

@main
struct PILExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func register(){
    print("Registering with \(username) + \(password) encrypted:\(secure) at \(domain):\(port)")
    pil.auth = Auth(username: username, password: password, domain: domain, port: port, secure: secure)
}

func unregister(){
    print("Unregistering..")
    pil.unregister()
}

func call(number: String) -> () -> () {
    return {
        _ = pil.call(number: number)
        print("Calling \(number)..")
    }
}
