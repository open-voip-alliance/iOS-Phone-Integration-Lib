//
//  VoIPGRIDMiddleware.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 16/02/2021.
//

import Foundation
import Alamofire
import PIL

class VoIPGRIDMiddleware: MiddlewareDelegate {
    private let defaults = UserDefaults.standard
    
    public func register(completion: @escaping (Bool) -> Void) {
        let username = defaults.object(forKey: "voipgrid_username") as? String ?? ""
        let sipUserId = defaults.object(forKey: "username") as? String ?? ""
        let pushKitToken = defaults.object(forKey: "push_kit_token") as? String ?? ""
        
        AF.request(
            "https://vialerpush.voipgrid.nl/api/apns-device/",
            method: .post,
            parameters: [
                "name" : username,
                "token" : pushKitToken,
                "sip_user_id" : sipUserId,
                "app" : "com.voipgrid.PILExampleApp"
            ],
            encoder: URLEncodedFormParameterEncoder.default,
            headers: createAuthHeader()
        ).response { response in
            switch response.result {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }
    
    public func unregister(completion: @escaping (Bool) -> Void) {
        let sipUserId = defaults.object(forKey: "username") as? String ?? ""
        let pushKitToken = defaults.object(forKey: "push_kit_token") as? String ?? ""
        
        AF.request(
            "https://vialerpush.voipgrid.nl/api/apns-device/",
            method: .delete,
            parameters: [
                "token" : pushKitToken,
                "sip_user_id" : sipUserId,
                "app" : "com.voipgrid.PILExampleApp"
            ],
            encoder: URLEncodedFormParameterEncoder.default,
            headers: createAuthHeader()
        ).response { response in
            switch response.result {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }
    
    public func respond(payload: NSDictionary, available: Bool) {
        let sipUserId = defaults.object(forKey: "username") as? String ?? ""
        
        AF.request(
            "https://vialerpush.voipgrid.nl/api/call-response/",
            method: .post,
            parameters: [
                "unique_key" : payload["unique_key"] as! String,
                "available" : available ? "true" : "false",
                "sip_user_id" : sipUserId,
                "message_start_time" : payload["message_start_time"] as! String
            ],
            encoder: URLEncodedFormParameterEncoder.default,
            headers: createAuthHeader()
        ).response { response in
            switch response.result {
                case .success(_):
                    print("Succcess")
                case .failure(_):
                    print("Failure")
                }
        }
    }
    
    private func createAuthHeader() -> HTTPHeaders {
        let username = defaults.object(forKey: "voipgrid_username") as? String ?? ""
        let apiToken = defaults.object(forKey: "voipgrid_api_token") as? String ?? ""
        
        return ["Authorization" : "Token \(username):\(apiToken)"]
    }
    
    func tokenReceived(token: String) {
        print("Received pktoken \(token)")
        defaults.set(token, forKey: "push_kit_token")
    }

}
