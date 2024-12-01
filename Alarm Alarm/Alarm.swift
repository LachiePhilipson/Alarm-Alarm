//
//  Alarm.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 13/12/2024.
//

import Foundation

struct Alarm: Codable, Identifiable, Equatable {
    let id: UUID
    var label: String
    var time: Date
    var enabled: Bool
    var snooze: Bool
    var snoozeTime: Int
    var sound = "Piano"
    var slowlyIncreaseVolume: Bool
    static let availableSounds = [
        "Piano",
        "Chimes",
    ]
}
