//
//  PushKitManager.swift
//  PIL
//
//  Created by Chris Kontos on 20/01/2021.
//

import Foundation
import PushKit

class PushKitManager: NSObject {
    
    private lazy var pil: PIL = PIL.shared
    private lazy var middlewareDelegate = {
        pil.middlewareDelegate
    }()

    private let voIPRegistry = PKPushRegistry(queue: nil)
    private let voIPPushHandler = VoIPPushHandler()
    private let notifications = NotificationCenter.default

    var token: String? {
        get {
            guard let token = voIPRegistry.pushToken(for: PKPushType.voIP) else {
                return nil
            }

            return String(apnsToken: token)
        }
    }

    /**
        Register to receive push notifications, this method can be called as regularly as needed
        and will not duplicate registrations or cause unnecessary traffic.
    */
    func registerForVoIPPushes() {
        if hasRegisteredForVoIPPushes() {
            if let token = self.token {
                middlewareDelegate?.sendToken?(token: token)
            }
            return
        }

        self.voIPRegistry.delegate = self
        self.voIPRegistry.desiredPushTypes = [.voIP]
    }

    /**
        Check if we have registered for voip pushes by seeing if the delgate is registered.
    */
    private func hasRegisteredForVoIPPushes() -> Bool {
        return self.voIPRegistry.delegate != nil
    }
}

extension PushKitManager: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = String(apnsToken: pushCredentials.token)
        print("Received a new APNS token: \(token)")

        middlewareDelegate?.sendToken?(token: token)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> ()) {
        print("Received a push notification of type \(type.rawValue)")

        switch type {
        case .voIP:
            voIPPushHandler.handle(payload: payload, completion: completion)
        default:
            print("Unknown incoming push \(type.rawValue)")
        }
    }
}

extension String {
    public init(apnsToken: Data) {
        self = apnsToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}
