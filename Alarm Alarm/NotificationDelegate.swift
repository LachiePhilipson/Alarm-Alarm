//
//  NotificationDelegate.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 16/12/2024.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "SNOOZE_ACTION" {
            let snoozeTime = UserDefaults.standard.integer(forKey: "snoozeTime")
            let request = AlarmNotificationController.shared.createSnoozeRequest(
                fromNotification: response.notification,
                snoozeMinutes: snoozeTime
            )

            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)

        } else if response.actionIdentifier == "STOP_ACTION" {
            if let alarmId = response.notification.request.content.userInfo["alarmId"] as? String {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["snoozedAlarm-\(alarmId)"])
            }
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
