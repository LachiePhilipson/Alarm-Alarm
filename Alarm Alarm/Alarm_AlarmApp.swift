import Foundation
import SwiftUI
import UserNotifications

@main
struct Alarm_AlarmApp: App {
    @StateObject private var alarmManager = AlarmManager.shared
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environmentObject(alarmManager)
        }
    }
}

