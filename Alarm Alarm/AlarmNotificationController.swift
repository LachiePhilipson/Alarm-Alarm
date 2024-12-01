import Foundation
import UserNotifications

class AlarmNotificationController {
    static let shared = AlarmNotificationController()

    // MARK: - Types

    private enum NotificationType {
        case alarm
        case snooze
    }

    private enum UserInfoKey {
        static let alarmId = "alarmId"
        static let sound = "sound"
        static let label = "alarmLabel"
        static let slowlyIncreaseVolume = "slowlyIncreaseVolume"
    }

    private enum Defaults {
        static let label = "Time to get up!"
        static let sound = "piano"
        static let snoozeInterval: TimeInterval = 60.0
    }

    static let snoozeCategory = "ALARM_CATEGORY_SNOOZE"
    static let noSnoozeCategory = "ALARM_CATEGORY_NO_SNOOZE"

    // MARK: - Init

    private init() {
        registerNotificationCategories()
    }

    // MARK: - Public Methods

    func scheduleAlarm(alarm: Alarm) {
        let request = createAlarmRequest(alarm: alarm)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling alarm: \(error)")
            }
        }
    }

    func cancelAlarm(alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                createIdentifier(.alarm, alarmId: alarm.id.uuidString)
            ]
        )
    }

    // MARK: - Request Creation

    private func createAlarmRequest(alarm: Alarm) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = alarm.label
        content.sound = createNotificationSound(
            name: alarm.sound, increasing: alarm.slowlyIncreaseVolume)
        content.categoryIdentifier =
            alarm.snooze ? Self.snoozeCategory : Self.noSnoozeCategory
        content.userInfo = createUserInfo(from: alarm)

        let trigger = createTrigger(from: alarm.time)
        let identifier = createIdentifier(.alarm, alarmId: alarm.id.uuidString)

        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }

    func createSnoozeRequest(
        fromNotification notification: UNNotification,
        snoozeMinutes: Int
    ) -> UNNotificationRequest {
        let userInfo = notification.request.content.userInfo
        let content = UNMutableNotificationContent()
        content.title = "Snoozed Alarm"
        content.body = userInfo[UserInfoKey.label] as? String ?? Defaults.label

        let sound = userInfo[UserInfoKey.sound] as? String ?? Defaults.sound
        let slowlyIncreaseVolume =
            userInfo[UserInfoKey.slowlyIncreaseVolume] as? Bool ?? false
        content.sound = createNotificationSound(
            name: sound, increasing: slowlyIncreaseVolume)

        content.categoryIdentifier = Self.snoozeCategory
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Double(snoozeMinutes) * Defaults.snoozeInterval,
            repeats: true
        )

        let alarmId =
            userInfo[UserInfoKey.alarmId] as? String ?? UUID().uuidString
        let identifier = createIdentifier(.snooze, alarmId: alarmId)

        return UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger)
    }

    // MARK: - Helper Methods

    private func createNotificationSound(name: String, increasing: Bool)
        -> UNNotificationSound
    {
        let soundFileName = increasing ? "\(name)-increasing" : name
        return UNNotificationSound(
            named: UNNotificationSoundName("\(soundFileName).wav"))
    }

    private func createUserInfo(from alarm: Alarm) -> [String: Any] {
        return [
            UserInfoKey.alarmId: alarm.id.uuidString,
            UserInfoKey.sound: alarm.sound,
            UserInfoKey.label: alarm.label,
            UserInfoKey.slowlyIncreaseVolume: alarm.slowlyIncreaseVolume,
        ]
    }

    private func createTrigger(from date: Date) -> UNCalendarNotificationTrigger
    {
        let components = Calendar.current.dateComponents(
            [.hour, .minute], from: date)
        return UNCalendarNotificationTrigger(
            dateMatching: components, repeats: true)
    }

    private func createIdentifier(_ type: NotificationType, alarmId: String)
        -> String
    {
        switch type {
        case .alarm: return "alarm-\(alarmId)"
        case .snooze: return "snoozedAlarm-\(alarmId)"
        }
    }

    private func registerNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: []
        )

        let stopAction = UNNotificationAction(
            identifier: "STOP_ACTION",
            title: "Stop",
            options: []
        )

        let snoozeCategory = UNNotificationCategory(
            identifier: AlarmNotificationController.snoozeCategory,
            actions: [snoozeAction, stopAction],
            intentIdentifiers: [],
            options: []
        )

        let noSnoozeCategory = UNNotificationCategory(
            identifier: AlarmNotificationController.noSnoozeCategory,
            actions: [stopAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            snoozeCategory, noSnoozeCategory,
        ])
    }
}
