//
//  MissedCallNotification.swift
//  PIL
//
//  Created by Jeremy Norman on 26/08/2021.
//

import Foundation
import NotificationCenter

class MissedCallNotification {

    static let notificationIdentifier = "pil-missed_calls_notification"
    static public let callsAmountNotificationKey = "missedCallsCount"
    
    private let center: UNUserNotificationCenter
    
    init(center: UNUserNotificationCenter) {
        self.center = center
    }
        
    @available(iOS 12.0, *)
    func notify(call: Call) {
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            if let error = error {
                log("Unable to notify of missed call: \(error)", level: .warning)
                return
            }
            
            self.findExistingNotification { existingNotification in
                let content = existingNotification != nil ? self.updateExistingNotification(call: call, notification: existingNotification!) : self.createNewNotification(call: call)
                let request = UNNotificationRequest(identifier: MissedCallNotification.notificationIdentifier, content: content, trigger: nil)
                self.center.add(request, withCompletionHandler: nil)
            }
        }
    }
    
    private func createNewNotification(call: Call) -> UNMutableNotificationContent {
        let content = buildBaseNotificationContent()
        content.title = String(format: NSLocalizedString("notification_missed_call_title", comment: ""), 1)
        content.body = String(format: NSLocalizedString("notification_missed_call_subtitle", comment: ""), call.remotePartyHeading, 1)
        return content
    }
    
    private func updateExistingNotification(call: Call, notification: UNNotification) -> UNMutableNotificationContent {
        let callsAmount = notification.missedCallsCount + 1
        let content = buildBaseNotificationContent(callsAmount: callsAmount)
        content.title = String(format: NSLocalizedString("notification_missed_call_title", comment: ""), callsAmount)
        content.body = String(format: NSLocalizedString("notification_missed_call_subtitle", comment: ""), "", callsAmount)
        return content
    }
    
    private func buildBaseNotificationContent(callsAmount: Int = 1)  -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.userInfo[MissedCallNotification.callsAmountNotificationKey] = callsAmount
        return content
    }
    
    private func findExistingNotification(completion: @escaping  (UNNotification?) -> ()) {
        center.getDeliveredNotifications { notifications in
            completion(notifications.filter { notification in
                notification.request.identifier == MissedCallNotification.notificationIdentifier
            }.first)
        }
    }
}

extension UNNotification {
    
    // The number of missed calls that this notification is currently tracking.
    var missedCallsCount: Int {
        request.content.userInfo[MissedCallNotification.callsAmountNotificationKey] as? Int ?? 0
    }
}
