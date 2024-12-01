//
//  AlarmManager.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 14/12/2024.
//

import Foundation
import SwiftUI
import UserNotifications

class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
    @Published var notificationsEnabled: Bool = false
    @Published var alarms: [Alarm] = [] {
        didSet {
            saveAlarms()
        }
    }
    
    private let saveKey = "SavedAlarms"
    
    private init() {
        loadAlarms()
        requestNotificationPermissions()
        checkNotificationSettings()
    }
    
    private func loadAlarms() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return
        }
        
        alarms = decoded
        decoded.filter(\.enabled).forEach { scheduleAlarm($0) }
    }
    
    private func saveAlarms() {
        guard let encoded = try? JSONEncoder().encode(alarms) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: saveKey)
    }
    
    private func scheduleAlarm(_ alarm: Alarm) {
        AlarmNotificationController.shared.scheduleAlarm(alarm: alarm)
    }
    
    private func cancelAlarm(_ alarm: Alarm) {
        AlarmNotificationController.shared.cancelAlarm(alarm: alarm)
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationsEnabled = granted
            }
        }
    }
    
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let status = settings.authorizationStatus
                self?.notificationsEnabled = (status == .authorized || status == .provisional)
            }
        }
    }
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        scheduleAlarm(alarm)
    }
    
    func updateAlarm(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else {
            return
        }
        
        alarms[index] = alarm
        cancelAlarm(alarm)
        scheduleAlarm(alarm)
    }
    
    func removeAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        cancelAlarm(alarm)
    }
}
