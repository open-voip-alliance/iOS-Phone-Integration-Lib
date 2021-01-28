//
//  PushKitManager.swift
//  PIL
//
//  Created by Chris Kontos on 20/01/2021.
//

import Foundation
import PushKit

class PushKitManager: NSObject {

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
            if self.token != nil {
                notifications.post(name: Notification.Name.receivedApnsToken, object: nil) //wip replace this with middlewareDelegate method call
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
        self.voIPRegistry.delegate != nil
    }
}

extension PushKitManager: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = String(apnsToken: pushCredentials.token)
        print("Received a new APNS token: \(token)")
        notifications.post(name: Notification.Name.receivedApnsToken, object: nil) //wip replace with tokenReceived from middleware delegate 
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

extension Notification.Name {

    /**
        A notification that is emitted when a token has been received from the apns
        servers.
    */
    static let receivedApnsToken = Notification.Name("received-apns-token")
}

