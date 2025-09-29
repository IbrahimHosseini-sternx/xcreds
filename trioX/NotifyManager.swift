//
//  NotifyManager.swift
//  XCreds
//
//

import Cocoa
import UserNotifications

class NotifyManager {

    static let shared = NotifyManager()


    init() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        }

    }
    func sendMessage(message:String)  {
        let content = UNMutableNotificationContent()
        content.title = message

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)

    }
}
