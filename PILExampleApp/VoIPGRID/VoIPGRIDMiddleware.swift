//
//  VoIPGRIDMiddleware.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 16/02/2021.
//

import Foundation
import Alamofire
import PIL
import PushKit

class VoIPGRIDMiddleware: Middleware {
    private let defaults = UserDefaults.standard
    
    public var isVoipgridTokenValid: Bool {
        defaults.string(forKey: "voipgrid_api_token")?.isEmpty == false
    }
    
    public func register(completion: @escaping (Bool) -> Void) {
        let username = defaults.object(forKey: "voipgrid_username") as? String ?? ""
        let sipUserId = defaults.object(forKey: "username") as? String ?? ""
        let pushKitToken = defaults.object(forKey: "push_kit_token") as? String ?? ""
        print("Registering with \(pushKitToken)")
        AF.request(
            "https://vialerpush.voipgrid.nl/api/apns-device/",
            method: .post,
            parameters: [
                "name" : username,
                "token" : pushKitToken,
                "sip_user_id" : sipUserId,
                "app" : "com.voipgrid.PILExampleApp",
                "push_profile" : "once",
                "sandbox" : "true"
            ],
            headers: createAuthHeader()
        ).response { response in
            switch response.result {
                case .success(_):
                    print("Registered successfully with \(pushKitToken)")
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
    
    public func respond(payload: PKPushPayload, available: Bool) {
        let sipUserId = defaults.object(forKey: "username") as? String ?? ""
        
        AF.request(
            "https://vialerpush.voipgrid.nl/api/call-response/",
            method: .post,
            parameters: [
                "unique_key" : payload.dictionaryPayload["unique_key"] as! String,
                "available" : available ? "true" : "false",
                "sip_user_id" : sipUserId,
                "message_start_time" : String(describing: payload.dictionaryPayload["message_start_time"]!)
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
    
    func inspect(payload: PKPushPayload, type: PKPushType) {
        if (type != .voIP) {
            UserDefaults.standard.set(false, forKey: "middleware_is_registered")
        }        
    }

    public func setVoIPAccountEncryption(encryption: Bool, completion: @escaping (Bool) -> Void) {
        print("Setting Voipgrid app account with encryption: \(encryption)")
        
        AF.request(
            "https://partner.voipgrid.nl/api/mobile/profile/",
            method: .put,
            parameters: ["appaccount_use_encryption" : encryption],
            encoding: JSONEncoding.default,
            headers: createAuthHeader()
        ).response { response in
            switch response.result {
                case .success(_):
                    print("VoIP Account Encryption set to \(encryption) successfully.")
                    self.defaults.set(encryption, forKey: "VoIP Account Encryption")
                    completion(true)
                case .failure(_):
                    print("Error, could not set the VoIP account encryption to \(encryption).")
                    completion(false)
                }
        }
    }
    
    public func extractCallDetail(from payload: PKPushPayload) -> IncomingPayloadCallDetail {
        return IncomingPayloadCallDetail(
            phoneNumber: payload.dictionaryPayload["phonenumber"] as? String ?? "",
            callerId: payload.dictionaryPayload["caller_id"] as? String ?? ""
        )
    }
    
    internal func createAuthHeader() -> HTTPHeaders {
        let username = defaults.object(forKey: "voipgrid_username") as? String ?? ""
        let apiToken = defaults.object(forKey: "voipgrid_api_token") as? String ?? ""
        
        return ["Authorization" : "Token \(username):\(apiToken)"]
    }
    
    func tokenReceived(token: String) {
        print("Received pktoken \(token)")
        defaults.set(token, forKey: "push_kit_token")
    }

}
