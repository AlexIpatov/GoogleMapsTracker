//
//  NotificationCenter.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 24.04.2021.
//

import Foundation
import UserNotifications

class NotificationCenter {

    private let center = UNUserNotificationCenter.current()

    func notificationReminder() {
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted,
                                                                     error in
        guard granted else {
            return
        }
        self.sendNotificatioRequest(
            content: self.makeNotificationContent(),
            trigger: self.makeIntervalNotificatioTrigger()
        )
    }
        sendNotificatioRequest(content: makeNotificationContent(),
                               trigger: makeIntervalNotificatioTrigger())
    }

   private func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Уже 30 минут прошло!"
        content.body = "Вы давно не заходили в наше приложение"
        content.badge = 1
        return content
    }

    private func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            timeInterval: 1800,
            repeats: false
        )
    }

    private func sendNotificatioRequest(
        content: UNNotificationContent,
        trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(
            identifier: "alarm",
            content: content,
            trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }




}
